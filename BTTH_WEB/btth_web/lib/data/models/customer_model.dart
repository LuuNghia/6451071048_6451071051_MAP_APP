import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel { 
  String id; 
  String firstName; 
  String lastName; 
  String email; 
  String phone; 
  String username; 
  String gender; 
  DateTime? dateOfBirth;
  DateTime? createdAt; 
 
  CustomerModel({ 
    required this.id, 
    required this.firstName, 
    required this.lastName, 
    required this.email, 
    required this.phone, 
    required this.username, 
    required this.gender, 
    this.dateOfBirth,
    this.createdAt, 
  }); 
 
  factory CustomerModel.fromMap(Map<String, dynamic> map) { 
    return CustomerModel( 
      id: map['id'] ?? '', 
      firstName: map['firstName'] ?? '', 
      lastName: map['lastName'] ?? '', 
      email: map['email'] ?? '', 
      phone: map['phone'] ?? '', 
      username: map['username'] ?? '', 
      gender: map['gender'] ?? 'Not set', 
      dateOfBirth: map['dateOfBirth'] is Timestamp 
          ? (map['dateOfBirth'] as Timestamp).toDate() 
          : (map['dateOfBirth'] != null ? DateTime.tryParse(map['dateOfBirth'].toString()) : null),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null), 
    ); 
  }

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return CustomerModel.fromMap(data);
  }
 
  String get fullName => "$firstName $lastName"; 
} 