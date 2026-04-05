import 'package:amplify_flutter/amplify_flutter.dart';

/// Service for communicating with the AppSync GraphQL backend.
///
/// Uses raw GraphQL documents — no generated model classes required.
/// The schema is defined in amplify_outputs.json (WordEntry model).
class ApiService {
  /// Creates a new WordEntry in DynamoDB via the AppSync GraphQL API.
  ///
  /// The backend schema expects:
  ///   - word (String, required)
  ///   - definitions ([String], optional — populated later by backend)
  ///
  /// Returns the id of the created entry on success, or throws on failure.
  static Future<String?> createWordEntry({required String word}) async {
    const document = '''
      mutation CreateWordEntry(\$input: CreateWordEntryInput!) {
        createWordEntry(input: \$input) {
          id
          word
          definitions
          createdAt
          updatedAt
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: document,
      variables: {
        'input': {
          'word': word,
          'definitions': <String>[],
        },
      },
    );

    final response = await Amplify.API.mutate(request: request).response;

    if (response.hasErrors) {
      final errorMessages =
          response.errors.map((e) => e.message).join(', ');
      throw Exception('Failed to create word entry: $errorMessages');
    }

    safePrint('Created word entry: ${response.data}');
    return response.data;
  }
}
