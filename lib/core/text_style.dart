import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // ================= APP BAR =================
  static final appBarTitle = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ================= TITLES =================
  static final title = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );


  static final sectionTitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // ================= BODY TEXT =================
  static final body = GoogleFonts.poppins(
    fontSize: 15, // ❌ not 12
    fontWeight: FontWeight.w400,
  );

  static final small = GoogleFonts.poppins(
    fontSize: 14, // minimum allowed
    fontWeight: FontWeight.w400,
  );

  // ================= LIST ITEM =================
  static final itemName = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static final itemSub = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // ================= BUTTON =================
  static final button = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
