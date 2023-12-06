import 'package:dropdown_search/dropdown_search.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:flutter/material.dart';

Widget dropdownWidget(
    String selectedOption,
    Function(String?) onDropdownValueChanged,
    List<String> dropdownItems,
    String label,
    bool searchable) {
  return DropdownSearch<String>(
    dropdownButtonProps: DropdownButtonProps(color: Colors.white),
    dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            labelStyle: TextStyle(color: Colors.white)),
        baseStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    popupProps: PopupProps.menu(
      fit: FlexFit.loose,
      showSelectedItems: false,
      showSearchBox: searchable,
      menuProps: MenuProps(
          backgroundColor: CustomColors.sweetCorn,
          borderRadius: BorderRadius.circular(10)),
      /*searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: 'Select your $label',
              labelStyle: GoogleFonts.comicNeue(
                  textStyle: TextStyle(
                color: Colors.black,
              )),
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                      color: CustomColors.midnightExtress, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                      color: CustomColors.midnightExtress, width: 1)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
        )*/
    ),
    items: dropdownItems,
    onChanged: onDropdownValueChanged,
    selectedItem: label,
  );
}
