import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_storage/firebase_storage.dart";
import 'package:local_market/controller/user_controller.dart';
import "package:uuid/uuid.dart";
import "package:local_market/utils/utils.dart";
import "dart:io";

class ProductController {
  final Firestore _firestore = Firestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final String ref = "products";
  final String vendor_ref = "vendors";
  final UserController _userController = new UserController();

  Future<void> add(File productImage, String productName, String productDescription,String userId, String tagId, String subCategoryId, String categoryId, Map<String, dynamic> productDetails) async {
    // print('product Controller' + size.toString());
    String productId = Uuid().v1();
    String imageUrl = await Utils().uploadImage(productImage, productId);
    // print("Image Url " + imageUrl);
    // productDetails["image"] = imageUrl;
    _firestore.collection(ref).document(productId).setData(
      {
        "id" : productId,
        "name" : productName.toLowerCase(),
        "image" : imageUrl,
        "tag" : tagId,
        "subCategory" : subCategoryId,
        "category" : categoryId,
        "price" : productDetails['price'],
        "offerPrice" : productDetails['offerPrice'],
        "vendorId" : userId,
        "description" : productDescription
      }).then((value){
      _firestore.collection(ref).document(productId).collection(vendor_ref).document(userId).setData(productDetails).then((value){
        _firestore.collection('users').document(userId).collection(ref).document(productId).setData({
          "inStock":true,
          "id" : productId,
          }).catchError((e){
          throw e;
        });
      }).catchError((e){
        throw e;
      });
    }).catchError((e){
      print(e.toString());
    });
  }

  Future<List<Map<String, String> > > getWithPattern(String pattern) async {
    pattern = pattern.toLowerCase();

    List<Map<String, String> > results = new List<Map<String, String> >();

    QuerySnapshot snapshot = await _firestore.collection(ref).orderBy('name').startAt([pattern]).endAt([pattern + '\uf8ff']).getDocuments();
    // print(document.toString());
    snapshot.documents.forEach((doc){
      results.add({
        "id" : doc.data['id'],
        "name" : doc.data['name'],
        "image" : doc.data['image'],
        "price" : doc.data['price'],
        "offerPrice" : doc.data['offerPrice'],
        "vendorId" : doc.data['vendorId'],
        "description" : doc.data['description'],
        "category" : doc.data['category'],
        "subCategory" : doc.data['subCategory'],
        "tag" : doc.data['tag']
      });
    });
    return results;
  }

  Future<List<Map<String, String> > > getRelated(Map<String, String> product) async {
    List<Map<String, String> > results = new List<Map<String, String> >();
    QuerySnapshot snapshot = await _firestore.collection(ref).where('subCategory', isEqualTo: product['subCategory']).limit(20).getDocuments();
    snapshot.documents.forEach((doc){
      // print('dp : ' + dp[doc.data['id']].toString());
      results.add({
        "id" : doc.data['id'],
        "name" : doc.data['name'],
        "image" : doc.data['image'],
        "price" : doc.data['price'],
        "offerPrice" : doc.data['offerPrice'],
        "vendorId": doc.data['vendorId'],
        "description" : doc.data['description'],
        "category" : doc.data['category'],
        "subCategory" : doc.data['subCategory'],
        "tag" : doc.data['tag']
      });
    });
    return results;
  }

  Future<Map<String, String>> getVendor(String productId, String vendorId) async {
    await _firestore.collection(ref).document(productId).collection('vendors').document(vendorId).get();
  }

  Future<List<dynamic>> getVendorSize(String productId, String vendorId) async {
    DocumentSnapshot doc = await _firestore.collection(ref).document(productId).collection('vendors').document(vendorId).get();
    return doc.data['size'];
  }

  Future<List<Map<String, String> > > getVendors(String productId) async {
    List<Map<String, String> > results = new List<Map<String, String> >();
    QuerySnapshot snapshot = await _firestore.collection(ref).document(productId).collection('vendors').getDocuments();
    for(var i = 0; i < snapshot.documents.length; i++){
      DocumentSnapshot doc = snapshot.documents[i];
      DocumentSnapshot vendor = await _userController.getUser(doc.data['id']);
      // print(doc.data.toString());
      // print(doc.data['id'].toString());
      // print(vendor.data.toString());
      results.add({
        "price" : doc.data['price'],
        "offerPrice" : doc.data['offerPrice'],
        "inStock" : doc.data['inStock'],
        "name" : vendor.data['username'],
        "address" : vendor.data['address'],
        "id" : doc.data['id']
      });
    }
    // print(results);
    return results;
  }

  Future<DocumentSnapshot> get(String id) async {
    return (await _firestore.collection(ref).document(id).get());
  }

  Future<DocumentSnapshot> getPrice(String pid, String uid) async {
    return (await _firestore.collection(ref).document(pid).collection(vendor_ref).document(uid).get());
  }

  Future<void> updatePrice(String pid, String uid, Map<String, dynamic> details) async {
    DocumentSnapshot product = await _firestore.collection(ref).document(pid).get();
    if(int.parse(details['price']) < int.parse(product.data['price'])){
      await _firestore.collection(ref).document(pid).updateData({
        "price" : details['price'],
        "offerPrice": details['offerPrice'],
        "vendorId" : uid
      }).catchError((e){
        throw e;
      });
    }else{
      if(product.data['vendorId'] == uid){
        await _firestore.collection(ref).document(pid).updateData({
          "price" : details['price'],
          "offerPrice": details['offerPrice'],
          "vendorId" : uid
        }).catchError((e){
          throw e;
        });
      }
    }
    await _firestore.collection(ref).document(pid).collection(vendor_ref).document(uid).setData(details).catchError((e){
      throw e;
    });
  }

  Future<List<DocumentSnapshot>> getNByTag(String subCategory,String tag, int n) async {
    QuerySnapshot snapshot = await _firestore.collection(ref).where('subCategory', isEqualTo: subCategory).where('tag', isEqualTo: tag).orderBy('name').limit(n).getDocuments();
    return snapshot.documents;
  }

  Future<List<DocumentSnapshot>> getNByTagNext(String subCategory,String tag, int n, String lastProductName) async {
    QuerySnapshot snapshot = await _firestore.collection(ref).where('subCategory', isEqualTo: subCategory).where('tag', isEqualTo: tag).orderBy('name').startAfter([lastProductName]).limit(n).getDocuments();
    return snapshot.documents;
  }


  Future<List<DocumentSnapshot>> getByTag(String subCategory, String tag) async {
    QuerySnapshot snapshot = await _firestore.collection(ref).where('subCategory', isEqualTo: subCategory).where('tag', isEqualTo: tag).orderBy('name').getDocuments();
    // print(snapshot.documents.toString());
    // snapshot.documents.forEach((f){
    //   print(f.data.toString());
    // });
    return snapshot.documents;
  }

  Future<List<DocumentSnapshot>> getBySubCategory(String subCategoryId) async {
    QuerySnapshot snapshot = await _firestore.collection(ref).where('subCategory', isEqualTo: subCategoryId).orderBy('name').getDocuments();

    return snapshot.documents;
  }

  Future<List<DocumentSnapshot>> getNBySubCategory(String subCategoryId, int n) async {
    QuerySnapshot snapshot = await _firestore.collection(ref).where('subCategory', isEqualTo: subCategoryId).orderBy('name').limit(n).getDocuments();

    return snapshot.documents;
  }

  Future<List<DocumentSnapshot>> getNBySubCategoryNext(String subCategoryId, int n, String lastProductName) async {
    QuerySnapshot snapshot = await _firestore.collection(ref).where('subCategory', isEqualTo: subCategoryId).orderBy('name').startAfter([lastProductName]).limit(n).getDocuments();

    return snapshot.documents;
  }

  Future<List<DocumentSnapshot>> getNByCategory(String categoryId, int n) async {
    QuerySnapshot snapshot = await _firestore.collection(ref).where('category', isEqualTo: categoryId).limit(n).getDocuments();

    return snapshot.documents;
  }
}