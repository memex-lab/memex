import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memex/data/services/openai_auth_service.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

class OpenAiConfigPage extends StatefulWidget {
  const OpenAiConfigPage({super.key});

  @override
  State<OpenAiConfigPage> createState() => _OpenAiConfigPageState();
}

class _OpenAiConfigPageState extends State<OpenAiConfigPage> {
  List<dynamic> _models = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedModel = prefs.getString('openai_default_model');

      final models = await OpenAiAuthService.getModels();
      if (mounted) {
        setState(() {
          _models = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSelectedModel(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openai_default_model', modelId);
    setState(() {
      _selectedModel = modelId;
    });

    // Sync selected model to backend
    try {
      final tokens = await OpenAiAuthService.getSavedTokens();
      if (tokens != null) {
        tokens['selectedModel'] = modelId;
        await MemexRouter().saveOpenAiAuth(tokens);
      }
    } catch (e) {
      // Don't block UI for sync failure
    }

    if (mounted) {
      ToastHelper.showSuccess(
          context, UserStorage.l10n.modelSetAsDefault(modelId));
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(child: AgentLogoLoading());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                UserStorage.l10n.loadModelListFailed(_error!),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadData();
                },
                child: Text(UserStorage.l10n.retry),
              )
            ],
          ),
        ),
      );
    }

    if (_models.isEmpty) {
      return Center(child: Text(UserStorage.l10n.noModelsFound));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _models.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final model = _models[index];
        final id = model['id']?.toString() ??
            model['slug']?.toString() ??
            UserStorage.l10n.unknownModel;
        final description = model['description']?.toString() ?? '';
        final isSelected = id == _selectedModel;

        return ListTile(
          title: Text(id, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: description.isNotEmpty
              ? Text(description, maxLines: 2, overflow: TextOverflow.ellipsis)
              : null,
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () => _saveSelectedModel(id),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: isSelected ? Colors.green.withOpacity(0.05) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.openAiModelConfig),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      body: _buildContent(),
    );
  }
}
