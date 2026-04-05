import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../models/word_base.dart';
import '../services/api_service.dart';

/// Word Capture page — allows the user to add a new word to their WordBase.
///
/// Per 0002-initial-architecture:
///   "Capture Vocab Page: Allows you to implement a new word into the WordBase"
///
/// The user enters:
///   - Word (required) — a single valid English word
///   - Associations (optional) — free-form text the user associates with the word
///
/// Fields NOT entered by the user (populated later by backend/API):
///   - Definition — will come from a dictionary database
///   - Crossword clues — will be generated/fetched
class WordCapturePage extends StatefulWidget {
  final WordBase wordBase;

  const WordCapturePage({super.key, required this.wordBase});

  @override
  State<WordCapturePage> createState() => _WordCapturePageState();
}

class _WordCapturePageState extends State<WordCapturePage> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _associationsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordController.dispose();
    _associationsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    debugPrint('[_handleSubmit] called');

    if (!_formKey.currentState!.validate()) {
      debugPrint('[_handleSubmit] form validation failed');
      return;
    }

    final word = _wordController.text.trim();
    debugPrint('[_handleSubmit] word="$word"');

    if (widget.wordBase.contains(word)) {
      debugPrint('[_handleSubmit] word already in WordBase');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$word" is already in your WordBase.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Send the word to the backend via GraphQL API.
      debugPrint('[_handleSubmit] calling ApiService.createWordEntry...');
      final result = await ApiService.createWordEntry(word: word);
      debugPrint('[_handleSubmit] API response: $result');

      // Add to local WordBase on success.
      final entry = WordEntry(
        word: word,
        // Definition and crossword clues are NOT user input per the architecture.
        // They will be populated from a dictionary API / clue source in future.
        associations: _associationsController.text.trim().isNotEmpty
            ? _associationsController.text.trim()
            : null,
      );

      widget.wordBase.add(entry);
      debugPrint('[_handleSubmit] added to local WordBase');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added "$word" to your WordBase!')),
        );
      }

      // Clear the form for the next word
      _wordController.clear();
      _associationsController.clear();
      _formKey.currentState!.reset();
    } on Exception catch (e, stackTrace) {
      debugPrint('[_handleSubmit] ERROR: $e');
      debugPrint('[_handleSubmit] STACKTRACE: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save "$word": $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
      debugPrint('[_handleSubmit] done');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Word'),
      ),
      body: Column(
        children: [
          // Input form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Word input field
                  TextFormField(
                    controller: _wordController,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Word',
                      hintText: 'Enter a word',
                      prefixIcon: Icon(Icons.spellcheck),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a word';
                      }
                      if (value.trim().contains(' ')) {
                        return 'Please enter a single word';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Associations input field (optional, user input)
                  TextFormField(
                    controller: _associationsController,
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    onFieldSubmitted: (_) => _handleSubmit(),
                    decoration: const InputDecoration(
                      labelText: 'Associations (optional)',
                      hintText:
                          'What do you associate with this word?',
                      prefixIcon: Icon(Icons.lightbulb_outline),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isSubmitting ? 'Saving...' : 'Add to WordBase'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // Word list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Your WordBase',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${widget.wordBase.length}'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Word list
          Expanded(
            child: widget.wordBase.length == 0
                ? const Center(
                    child: Text(
                      'No words yet.\nAdd your first word above!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: widget.wordBase.length,
                    itemBuilder: (context, index) {
                      final entry = widget.wordBase.entries[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            entry.word,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: entry.associations != null
                              ? Text(entry.associations!)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              widget.wordBase.remove(entry.word);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Removed "${entry.word}" from WordBase.'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
