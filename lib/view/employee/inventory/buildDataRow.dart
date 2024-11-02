//Base imports
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/api/global_variables.dart';

//Page Imports
import 'package:jcsd_flutter/modals/edititem.dart';
import 'package:jcsd_flutter/modals/archiveitem.dart';

class BuildDataRow extends StatefulWidget {
  final String id;
  final String name;
  final String type;
  final String supplier;
  final String quantity;
  final String price;
  final Color quantityColor;

  
  const BuildDataRow({
    super.key,
    required this.id,
    required this.name,
    required this.type,
    required this.supplier,
    required this.quantity,
    required this.price,
    required this.quantityColor,
    });

  @override
  State<BuildDataRow> createState() => _BuildDataRowState();
}

class _BuildDataRowState extends State<BuildDataRow> {
  //Addt'l methods for the Edit and Archive item modals
  void _showEditItemModal(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const EditItemModal();
      },
    );
  }

  void _showArchiveItemModal(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ArchiveItemModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row( // Changed to Row
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added for spacing
      children: [
        Text(widget.id),
        Text(widget.name),
        Text(widget.type),
        Text(widget.supplier),
        Container( // Keep the quantity container
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: widget.quantityColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.quantity,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Text(widget.price),
        Row( // Keep the buttons in a Row
          children: [
            ElevatedButton(
              onPressed: _showEditItemModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Edit',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: _showArchiveItemModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

