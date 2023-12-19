import 'package:xchange_net/src/model/categorical.dart';
import 'package:xchange_net/src/model/numerical.dart';

class ProductSizeType {
  List<Numerical>? numerical;
  List<Categorical>? categorical;

  ProductSizeType({this.numerical, this.categorical});
}
