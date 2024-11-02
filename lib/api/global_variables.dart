import 'package:flutter/material.dart'; //
import 'package:supabase_flutter/supabase_flutter.dart'; //Supabase
import 'supa_details.dart';

//Initialize Supabase here
void supabase_init() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: returnAccessURL(),
    anonKey: returnAnonKey(),
  );
}

//Referencing Supabase across the models
final SupabaseClient supabaseDB = Supabase.instance.client;
