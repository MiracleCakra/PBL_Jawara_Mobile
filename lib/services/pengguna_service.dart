import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      // This will likely fail without service_role key, but it reflects the user's intent
      // final response = await _client.auth.admin.listUsers();
      // return response.users.map((user) => user.toJson()).toList();
      
      // Placeholder, as direct listing is not possible from client.
      // The correct implementation requires a backend call (e.g., Supabase Edge Function).
      print("Warning: Attempting to list users from the client-side. This requires admin privileges and will likely fail without a proper backend implementation.");
      final response = await _client.from('users').select();
      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      print('Error fetching users: $e');
      // Returning an empty list as a fallback
      return [];
    }
  }
}
