import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';

// assuming that your file is called filename.dart. This will give an error at first,
// but it's needed for moor to know about the generated code
part 'database.g.dart';

// this will generate a table called "todos" for us. The rows of that table will
// be represented by a class called "Todo".
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  IntColumn get category => integer().nullable()();
}

// This will make moor generate a class called "Category" to represent a row in this table.
// By default, "Categorie" would have been used because it only strips away the trailing "s"
// in the table name.
@DataClassName("Category")
class Categories extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
}

class Users extends Table {
  TextColumn get email => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {email};
}

class Words extends Table {
  TextColumn get word => text()();
  IntColumn get usages => integer().withDefault(const Constant<int>(1))();

  @override
  Set<Column> get primaryKey => {word};
}

// this annotation tells moor to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
@UseMoor(tables: [Todos, Categories, Users, Words])
class MyDatabase extends _$MyDatabase {
  MyDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // loads all todo entries
  Future<List<Todo>> get allTodoEntries => select(todos).get();

  // watches all todo entries in a given category. The stream will automatically
  // emit new items whenever the underlying data changes.
  Stream<List<Todo>> watchEntriesInCategory(Category c) {
    return (select(todos)..where((t) => t.category.equals(c.id))).watch();
  }

  Future<List<Todo>> limitTodos(int limit, {int? offset}) {
    return (select(todos)..limit(limit, offset: offset)).get();
  }

  Future<List<Todo>> sortEntriesAlphabetically() {
    return (select(todos)..orderBy([(t) => OrderingTerm(expression: t.title)])).get();
  }

  Stream<Todo> entryStreamById(int id) {
    return (select(todos)..where((t) => t.id.equals(id))).watchSingle();
  }

  Stream<List<String>> contentWithLongTitles() {
    final query = select(todos)
      ..where((t) => t.title.length.isBiggerOrEqualValue(16));

    return query
        .map((row) => row.content)
        .watch();
  }

  // Exposes `get` and `watch`
  MultiSelectable<Todo> pageOfTodos(int page, {int pageSize = 10}) {
    return select(todos)..limit(pageSize, offset: page);
  }

  // Exposes `getSingle` and `watchSingle`
  SingleSelectable<Todo> entryById(int id) {
    return select(todos)..where((t) => t.id.equals(id));
  }

  // Exposes `getSingleOrNull` and `watchSingleOrNull`
  SingleOrNullSelectable<Todo> entryFromExternalLink(int id) {
    return select(todos)..where((t) => t.id.equals(id));
  }

  Future moveImportantTasksIntoCategory(Category target) {
    // for updates, we use the "companion" version of a generated class. This wraps the
    // fields in a "Value" type which can be set to be absent using "Value.absent()". This
    // allows us to separate between "SET category = NULL" (`category: Value(null)`) and not
    // updating the category at all: `category: Value.absent()`.
    return (update(todos)
      ..where((t) => t.title.like('%Important%'))
    ).write(TodosCompanion(
      category: Value(target.id),
    ),
    );
  }

  Future updateTodo(Todo entry) {
    // using replace will update all fields from the entry that are not marked as a primary key.
    // it will also make sure that only the entry with the same primary key will be updated.
    // Here, this means that the row that has the same id as entry will be updated to reflect
    // the entry's title, content and category. As its where clause is set automatically, it
    // cannot be used together with where.
    return update(todos).replace(entry);
  }

  Future feelingLazy() {
    // delete the oldest nine tasks
    return (delete(todos)..where((t) => t.id.isSmallerThanValue(10))).go();
  }

  // returns the generated id
  // example:
  // ```
  // addTodo(
  //   TodosCompanion(
  //     title: Value('Important task'),
  //     content: Value('Refactor persistence code'),
  //   ),
  // );
  // ```
  Future<int> addTodo(TodosCompanion entry) {
    return into(todos).insert(entry);
  }

  Future<void> insertMultipleEntries() async{
    await batch((batch) {
      // functions in a batch don't have to be awaited - just
      // await the whole batch afterwards.
      batch.insertAll(todos, [
        TodosCompanion.insert(
          title: 'First entry',
          content: 'My content',
        ),
        TodosCompanion.insert(
          title: 'Another entry',
          content: 'More content',
          // columns that aren't required for inserts are still wrapped in a Value:
          category: Value(3),
        ),
        // ...
      ]);
    });
  }

  Future<void> createOrUpdateUser(User user) {
    return into(users).insertOnConflictUpdate(user);
  }

  Future<void> trackWord(String word) {
    return into(words).insert(
      WordsCompanion.insert(word: word),
      onConflict: DoUpdate((old) => WordsCompanion.custom(usages: old.usages + Constant(1))),
    );
  }

  Future<Todo> insertReturningTodo() {
    return into(todos).insertReturning(TodosCompanion.insert(
      title: 'A todo entry',
      content: 'A description',
    ));
  }

}