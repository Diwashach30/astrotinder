import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authFlowType: AuthFlowType.pkce,
    );
  }

  static User? get currentUser => client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static Future<dynamic> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<dynamic> signUpWithEmail(String email, String password) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      await createProfile(user.id, email);
    }

    return response;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> createProfile(String userId, String email) async {
    final profile = await client.from('profiles').upsert(
      {
        'id': userId,
        'email': email,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'id',
    ).select().maybeSingle();

    if (profile == null) {
      throw Exception('Unable to create or update profile.');
    }
  }

  static Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final profile = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return profile as Map<String, dynamic>?;
  }
}
