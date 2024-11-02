import 'package:supabase_flutter/supabase_flutter.dart';
 //For the Supabase implementation - usage of single SB 
import 'package:jcsd_flutter/api/global_variables.dart';
// Inventory Data model to store all the relevant data per instance of that model
import 'package:jcsd_flutter/models/inventory_data.dart';

class InventoryService {
  // ? included for possibility that it may be null
  Future<InventoryData?> getItemByID(int itemID) async{
    final getItem = await supabaseDB.from('item_inventory').select().eq('itemID', itemID).single(); //Gets specific not 

    //Catching the error based on the server response
    if(getItem. != null){
      
    }

  }
}