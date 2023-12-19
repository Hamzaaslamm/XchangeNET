import 'package:xchange_net/src/model/product_size_type.dart';

enum AdType { all, watch, mobile, headphone, tablet, tv }

class Ad {
  String name;
  int price;
  int? off;
  String about;
  bool isAvailable;
  ProductSizeType? sizes;
  int quantity;
  List<String> images;
  bool isLiked;
  double rating;
  AdType type;

  Ad(
      {required this.name,
        required this.price,
        required this.about,
        required this.isAvailable,
        this.sizes,
        required this.off,
        required this.quantity,
        required this.images,
        required this.isLiked,
        required this.rating,
        required this.type});
}
