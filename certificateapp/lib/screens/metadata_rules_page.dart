import 'package:flutter/material.dart';
import '../models/metadata_rule.dart';

class MetadataRulesPage extends StatefulWidget {
  const MetadataRulesPage({Key? key}) : super(key: key);

  @override
  State<MetadataRulesPage> createState() => _MetadataRulesPageState();
}

class _MetadataRulesPageState extends State<MetadataRulesPage> {
  final List<MetadataRule> _rules = [
    MetadataRule(
      id: '1',
      name: 'Certificate Number Format',
      description: 'Ensures certificate numbers follow the required format',
      fieldName: 'certificateNumber',
      fieldType: FieldType.text,
      ruleType: RuleType.format,
      pattern: r'^[A-Z]{3}-\d{4}-\d{3}$',
      errorMessage: 'Certificate number must follow format: XXX-YYYY-ZZZ',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      createdBy: 'admin@example.com',
    ),
    MetadataRule(
      id: '2',
      name: 'Issuer Name Required',
      description: 'Issuer name is mandatory for all certificates',
      fieldName: 'issuerName',
      fieldType: FieldType.text,
      ruleType: RuleType.required,
      isRequired: true,
      errorMessage: 'Issuer name is required',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      createdBy: 'admin@example.com',
    ),
    MetadataRule(
      id: '3',
      name: 'Expiry Date Range',
      description: 'Certificate expiry date must be within valid range',
      fieldName: 'expiryDate',
      fieldType: FieldType.date,
      ruleType: RuleType.range,
      minValue: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      maxValue: DateTime.now().add(const Duration(days: 365 * 5)).toIso8601String(),
      errorMessage: 'Expiry date must be between tomorrow and 5 years from now',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      createdBy: 'admin@example.com',
    ),
    MetadataRule(
      id: '4',
      name: 'File Size Limit',
      description: 'Certificate file size must not exceed 10MB',
      fieldName: 'fileSize',
      fieldType: FieldType.number,
      ruleType: RuleType.range,
      maxValue: 10 * 1024 * 1024, // 10MB in bytes
      errorMessage: 'File size must not exceed 10MB',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      createdBy: 'admin@example.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata Rules'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRuleDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with statistics
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[50],
            child: Row(
              children: [
                _StatCard(
                  title: 'Total Rules',
                  value: _rules.length.toString(),
                  icon: Icons.rule,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Active Rules',
                  value: _rules.where((r) => r.isActive).length.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Inactive Rules',
                  value: _rules.where((r) => !r.isActive).length.toString(),
                  icon: Icons.pause_circle,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          
          // Rules List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rules.length,
              itemBuilder: (context, index) {
                final rule = _rules[index];
                return _RuleCard(
                  rule: rule,
                  onEdit: () => _showEditRuleDialog(rule),
                  onToggle: () => _toggleRule(rule),
                  onDelete: () => _showDeleteRuleDialog(rule),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRule(MetadataRule rule) {
    setState(() {
      final index = _rules.indexWhere((r) => r.id == rule.id);
      if (index != -1) {
        _rules[index] = rule.copyWith(isActive: !rule.isActive);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rule ${rule.isActive ? 'deactivated' : 'activated'}'),
      ),
    );
  }

  void _showAddRuleDialog() {
    showDialog(
      context: context,
      builder: (context) => _RuleDialog(
        rule: null,
        onSave: (rule) {
          setState(() {
            _rules.add(rule);
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rule added successfully')),
          );
        },
      ),
    );
  }

  void _showEditRuleDialog(MetadataRule rule) {
    showDialog(
      context: context,
      builder: (context) => _RuleDialog(
        rule: rule,
        onSave: (updatedRule) {
          setState(() {
            final index = _rules.indexWhere((r) => r.id == rule.id);
            if (index != -1) {
              _rules[index] = updatedRule;
            }
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rule updated successfully')),
          );
        },
      ),
    );
  }

  void _showDeleteRuleDialog(MetadataRule rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text('Are you sure you want to delete "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _rules.removeWhere((r) => r.id == rule.id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rule deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final MetadataRule rule;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _RuleCard({
    required this.rule,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rule.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: rule.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: rule.isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                            child: Text(
                              rule.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: rule.isActive ? Colors.green : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rule.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'toggle':
                        onToggle();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            rule.isActive ? Icons.pause : Icons.play_arrow,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(rule.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RuleDetailRow('Field', rule.fieldName),
            _RuleDetailRow('Type', '${rule.fieldType.name} (${rule.ruleType.name})'),
            if (rule.isRequired) _RuleDetailRow('Required', 'Yes'),
            if (rule.pattern != null) _RuleDetailRow('Pattern', rule.pattern!),
            if (rule.minValue != null) _RuleDetailRow('Min Value', rule.minValue.toString()),
            if (rule.maxValue != null) _RuleDetailRow('Max Value', rule.maxValue.toString()),
            if (rule.errorMessage != null) _RuleDetailRow('Error Message', rule.errorMessage!),
            _RuleDetailRow('Created', rule.createdAt.toString().split(' ')[0]),
            _RuleDetailRow('Created By', rule.createdBy),
          ],
        ),
      ),
    );
  }
}

class _RuleDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _RuleDetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleDialog extends StatefulWidget {
  final MetadataRule? rule;
  final Function(MetadataRule) onSave;

  const _RuleDialog({
    this.rule,
    required this.onSave,
  });

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _fieldNameController;
  late TextEditingController _patternController;
  late TextEditingController _minValueController;
  late TextEditingController _maxValueController;
  late TextEditingController _errorMessageController;
  
  FieldType _selectedFieldType = FieldType.text;
  RuleType _selectedRuleType = RuleType.required;
  bool _isRequired = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name ?? '');
    _descriptionController = TextEditingController(text: widget.rule?.description ?? '');
    _fieldNameController = TextEditingController(text: widget.rule?.fieldName ?? '');
    _patternController = TextEditingController(text: widget.rule?.pattern ?? '');
    _minValueController = TextEditingController(text: widget.rule?.minValue?.toString() ?? '');
    _maxValueController = TextEditingController(text: widget.rule?.maxValue?.toString() ?? '');
    _errorMessageController = TextEditingController(text: widget.rule?.errorMessage ?? '');
    
    if (widget.rule != null) {
      _selectedFieldType = widget.rule!.fieldType;
      _selectedRuleType = widget.rule!.ruleType;
      _isRequired = widget.rule!.isRequired;
      _isActive = widget.rule!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fieldNameController.dispose();
    _patternController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    _errorMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? 'Add Rule' : 'Edit Rule'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Rule Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rule name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldNameController,
                decoration: const InputDecoration(
                  labelText: 'Field Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Field name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<FieldType>(
                      value: _selectedFieldType,
                      decoration: const InputDecoration(
                        labelText: 'Field Type',
                        border: OutlineInputBorder(),
                      ),
                      items: FieldType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFieldType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<RuleType>(
                      value: _selectedRuleType,
                      decoration: const InputDecoration(
                        labelText: 'Rule Type',
                        border: OutlineInputBorder(),
                      ),
                      items: RuleType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRuleType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isRequired,
                    onChanged: (value) {
                      setState(() {
                        _isRequired = value!;
                      });
                    },
                  ),
                  const Text('Required Field'),
                  const Spacer(),
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value!;
                      });
                    },
                  ),
                  const Text('Active'),
                ],
              ),
              if (_selectedRuleType == RuleType.format) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _patternController,
                  decoration: const InputDecoration(
                    labelText: 'Pattern (Regex)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (_selectedRuleType == RuleType.range) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minValueController,
                        decoration: const InputDecoration(
                          labelText: 'Min Value',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxValueController,
                        decoration: const InputDecoration(
                          labelText: 'Max Value',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _errorMessageController,
                decoration: const InputDecoration(
                  labelText: 'Error Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveRule,
          child: Text(widget.rule == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _saveRule() {
    if (_formKey.currentState!.validate()) {
      final rule = MetadataRule(
        id: widget.rule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        fieldName: _fieldNameController.text.trim(),
        fieldType: _selectedFieldType,
        ruleType: _selectedRuleType,
        isRequired: _isRequired,
        pattern: _patternController.text.trim().isEmpty ? null : _patternController.text.trim(),
        minValue: _minValueController.text.trim().isEmpty ? null : _minValueController.text.trim(),
        maxValue: _maxValueController.text.trim().isEmpty ? null : _maxValueController.text.trim(),
        errorMessage: _errorMessageController.text.trim().isEmpty ? null : _errorMessageController.text.trim(),
        isActive: _isActive,
        createdAt: widget.rule?.createdAt ?? DateTime.now(),
        createdBy: widget.rule?.createdBy ?? 'admin@example.com',
      );
      
      widget.onSave(rule);
    }
  }
} 