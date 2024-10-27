import 'package:flutter/material.dart'; //
import 'package:supabase_flutter/supabase_flutter.dart'; //Supabase

//Initialize Supabase here
void supabase_init() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://taaxqkxerbpgftybxtws.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRhYXhxa3hlcmJwZ2Z0eWJ4dHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk5NDY2NTUsImV4cCI6MjA0NTUyMjY1NX0.dOajQSrc9wv1lPuN32PB6MGSc4ze53-jc-6UnwOiFBQ',
  );
}

//Referencing Supabase across the models
final supabaseDB = Supabase.instance.client;
