class BusinessModel {
  final int businessId;
  final String businessName;
  final String contactNumber;
  final String businessEmail;
  final int businessAddress;
  final int businessOwnerId;
  final int businessTypeId;
  final String businessImage;

  BusinessModel({
    required this.businessId,
    required this.businessName,
    required this.contactNumber,
    required this.businessEmail,
    required this.businessAddress,
    required this.businessOwnerId,
    required this.businessTypeId,
    required this.businessImage,
  });

  factory BusinessModel.fromJSon(Map<String, dynamic> json) {
    return BusinessModel(
      businessId: json['id'] ?? '',
      businessName: json['name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      businessEmail: json['email'] ?? '',
      businessAddress: json['location'] ?? 0,
      businessOwnerId: json['owner'] ?? 0,
      businessTypeId: json['business_type'] ?? 0,
      businessImage: json['image'] ?? '',
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'name': businessName,
      'contact_number': contactNumber,
      'email': businessEmail,
      'owner': businessOwnerId,
      'business_type': businessTypeId,
    };
  }
}

class Category {
  final int categoryId;
  final String categoryName;

  Category({
    required this.categoryId,
    required this.categoryName,
  });

  factory Category.fromJSon(Map<String, dynamic> json) {
    return Category(
      categoryId: json['id'] ?? '',
      categoryName: json['name'] ?? '',
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'id': categoryId,
      'name': categoryName,
    };
  }
}

class Products {
  final int productId;
  final String productName;
  final String productDescription;
  final String productPrice;
  final int stockAvailable;
  final int businessId;
  final int productTypeId;
  final String productImage;
  final int seller;

  Products(
      {required this.productId,
      required this.productName,
      required this.productDescription,
      required this.productPrice,
      required this.stockAvailable,
      required this.businessId,
      required this.productTypeId,
      required this.productImage,
      required this.seller});

  factory Products.fromJSon(Map<String, dynamic> json) {
    return Products(
      productId: json['id'] ?? '',
      productName: json['name'] ?? '',
      productDescription: json['description'] ?? '',
      productPrice: json['price'] ?? '',
      stockAvailable: json['stock'] ?? 0,
      businessId: json['business'] ?? 0,
      productTypeId: json['category'] ?? 0,
      productImage: json['image'] ?? '',
      seller: json['seller'] ?? 0,
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'name': productName,
      'description': productDescription,
      'price': productPrice,
      'stock': stockAvailable,
      'business': businessId,
      'category': productTypeId,
      'image': productImage,
    };
  }
}
