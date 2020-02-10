import 'dart:ffi';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initDb();
    }
    return _db;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE contacts(id INTEGER PRIMARY KEY, name TEXT, email TEXT, phone TEXT, img TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    final db = await this.db;
    contact.id = await db.insert("contacts", contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    final db = await this.db;
    List<Map> maps = await db.query("contacts",
        columns: ['id','name','email','phone','img'],
        where: "id=?", whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else return null;
  }

  Future<int> deleteContact(int id) async {
    final db = await this.db;
    return await db.delete("contacts", where: "id=?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    final db = await this.db;
    return await db.update("contacts", contact.toMap(), where: "id = ?", whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await this.db;
    List maps = await db.rawQuery("SELECT * FROM contacts");
    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<int> getNumber() async {
    final db = await this.db;
    return Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM contacts"));
  }

  Future<void> close() async {
    final db = await this.db;
    db.close();
  }
}

class Contact {

  int id;
  String name,email,phone,img;

  Contact({this.name,this.email,this.phone,this.img});

  Contact.fromMap(Map map) {
    this.id = map['id'];
    this.name = map['name'];
    this.email = map['email'];
    this.phone = map['phone'];
    this.img = map['img'];
  }

  Map toMap() {
    Map<String, dynamic> map = {'name':name,'email':email,'phone':phone,'img':img};
    if (id != null) map['id'] = id;
    return map;
  }

  @override
  String toString() {
    return "Contact(id:$id,name:$name,email:$email,phone:$phone,img:$img)";
  }
}