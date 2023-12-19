import 'package:xchange_net/src/model/ad.dart';
import 'package:flutter/material.dart';

class AdCategory {
  AdType type;
  bool isSelected;
  IconData icon;

  AdCategory(this.type, this.isSelected, this.icon);
}
