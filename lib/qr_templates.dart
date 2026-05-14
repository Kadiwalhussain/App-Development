import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/services/history_service.dart';

class QrTemplate {
  final String name;
  final IconData icon;
  final Color color;
  final List<TemplateField> fields;
  final String Function(Map<String, String> values) generateData;

  const QrTemplate({
    required this.name,
    required this.icon,
    required this.color,
    required this.fields,
    required this.generateData,
  });
}

class TemplateField {
  final String key;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool isOptional;

  const TemplateField({
    required this.key,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.isOptional = false,
  });
}

final List<QrTemplate> qrTemplates = [
  QrTemplate(
    name: 'URL',
    icon: Icons.link,
    color: Colors.blue,
    fields: [
      TemplateField(
        key: 'url',
        label: 'Website URL',
        hint: 'https://example.com',
        keyboardType: TextInputType.url,
      ),
    ],
    generateData: (values) => values['url'] ?? '',
  ),
  QrTemplate(
    name: 'Email',
    icon: Icons.email,
    color: Colors.red,
    fields: [
      TemplateField(
        key: 'email',
        label: 'Email Address',
        hint: 'example@email.com',
        keyboardType: TextInputType.emailAddress,
      ),
      TemplateField(
        key: 'subject',
        label: 'Subject',
        hint: 'Email subject',
        isOptional: true,
      ),
      TemplateField(
        key: 'body',
        label: 'Message',
        hint: 'Email body',
        isOptional: true,
      ),
    ],
    generateData: (values) {
      String data = 'mailto:${values['email']}';
      List<String> params = [];
      if (values['subject']?.isNotEmpty ?? false) {
        params.add('subject=${Uri.encodeComponent(values['subject']!)}');
      }
      if (values['body']?.isNotEmpty ?? false) {
        params.add('body=${Uri.encodeComponent(values['body']!)}');
      }
      if (params.isNotEmpty) {
        data += '?${params.join('&')}';
      }
      return data;
    },
  ),
  QrTemplate(
    name: 'Phone',
    icon: Icons.phone,
    color: Colors.green,
    fields: [
      TemplateField(
        key: 'phone',
        label: 'Phone Number',
        hint: '+1234567890',
        keyboardType: TextInputType.phone,
      ),
    ],
    generateData: (values) => 'tel:${values['phone']}',
  ),
  QrTemplate(
    name: 'SMS',
    icon: Icons.message,
    color: Colors.orange,
    fields: [
      TemplateField(
        key: 'phone',
        label: 'Phone Number',
        hint: '+1234567890',
        keyboardType: TextInputType.phone,
      ),
      TemplateField(
        key: 'message',
        label: 'Message',
        hint: 'Your message here',
        isOptional: true,
      ),
    ],
    generateData: (values) {
      String data = 'sms:${values['phone']}';
      if (values['message']?.isNotEmpty ?? false) {
        data += '?body=${Uri.encodeComponent(values['message']!)}';
      }
      return data;
    },
  ),
  QrTemplate(
    name: 'WiFi',
    icon: Icons.wifi,
    color: Colors.purple,
    fields: [
      TemplateField(
        key: 'ssid',
        label: 'Network Name (SSID)',
        hint: 'MyWiFiNetwork',
      ),
      TemplateField(
        key: 'password',
        label: 'Password',
        hint: 'WiFi password',
        isOptional: true,
      ),
    ],
    generateData: (values) {
      String encryption = (values['password']?.isNotEmpty ?? false) ? 'WPA' : 'nopass';
      String password = values['password'] ?? '';
      return 'WIFI:T:$encryption;S:${values['ssid']};P:$password;;';
    },
  ),
  QrTemplate(
    name: 'Contact',
    icon: Icons.contact_page,
    color: Colors.teal,
    fields: [
      TemplateField(
        key: 'name',
        label: 'Full Name',
        hint: 'John Doe',
      ),
      TemplateField(
        key: 'phone',
        label: 'Phone Number',
        hint: '+1234567890',
        keyboardType: TextInputType.phone,
        isOptional: true,
      ),
      TemplateField(
        key: 'email',
        label: 'Email',
        hint: 'john@example.com',
        keyboardType: TextInputType.emailAddress,
        isOptional: true,
      ),
      TemplateField(
        key: 'company',
        label: 'Company',
        hint: 'Company name',
        isOptional: true,
      ),
    ],
    generateData: (values) {
      StringBuffer vcard = StringBuffer();
      vcard.writeln('BEGIN:VCARD');
      vcard.writeln('VERSION:3.0');
      vcard.writeln('FN:${values['name']}');
      if (values['phone']?.isNotEmpty ?? false) {
        vcard.writeln('TEL:${values['phone']}');
      }
      if (values['email']?.isNotEmpty ?? false) {
        vcard.writeln('EMAIL:${values['email']}');
      }
      if (values['company']?.isNotEmpty ?? false) {
        vcard.writeln('ORG:${values['company']}');
      }
      vcard.writeln('END:VCARD');
      return vcard.toString();
    },
  ),
  QrTemplate(
    name: 'Location',
    icon: Icons.location_on,
    color: Colors.pink,
    fields: [
      TemplateField(
        key: 'latitude',
        label: 'Latitude',
        hint: '37.7749',
        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
      ),
      TemplateField(
        key: 'longitude',
        label: 'Longitude',
        hint: '-122.4194',
        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
      ),
    ],
    generateData: (values) => 'geo:${values['latitude']},${values['longitude']}',
  ),
  QrTemplate(
    name: 'Event',
    icon: Icons.event,
    color: Colors.indigo,
    fields: [
      TemplateField(
        key: 'title',
        label: 'Event Title',
        hint: 'Meeting',
      ),
      TemplateField(
        key: 'location',
        label: 'Location',
        hint: 'Conference Room',
        isOptional: true,
      ),
      TemplateField(
        key: 'description',
        label: 'Description',
        hint: 'Event details',
        isOptional: true,
      ),
    ],
    generateData: (values) {
      StringBuffer event = StringBuffer();
      event.writeln('BEGIN:VEVENT');
      event.writeln('SUMMARY:${values['title']}');
      if (values['location']?.isNotEmpty ?? false) {
        event.writeln('LOCATION:${values['location']}');
      }
      if (values['description']?.isNotEmpty ?? false) {
        event.writeln('DESCRIPTION:${values['description']}');
      }
      event.writeln('END:VEVENT');
      return event.toString();
    },
  ),
];

class QrTemplatesScreen extends StatelessWidget {
  const QrTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quick Templates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: qrTemplates.length,
          itemBuilder: (context, index) {
            final template = qrTemplates[index];
            return _TemplateCard(template: template);
          },
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final QrTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TemplateFormScreen(template: template),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                template.color.withValues(alpha: 0.8),
                template.color.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(template.icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                template.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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

class TemplateFormScreen extends StatefulWidget {
  final QrTemplate template;

  const TemplateFormScreen({super.key, required this.template});

  @override
  State<TemplateFormScreen> createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends State<TemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String? _generatedData;

  @override
  void initState() {
    super.initState();
    for (var field in widget.template.fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _generateQrCode() {
    if (_formKey.currentState!.validate()) {
      final values = <String, String>{};
      for (var entry in _controllers.entries) {
        values[entry.key] = entry.value.text;
      }
      setState(() {
        _generatedData = widget.template.generateData(values);
      });
      // Save to history
      HistoryService.addToHistory(_generatedData!, false);
    }
  }

  void _clearForm() {
    setState(() {
      _generatedData = null;
      for (var controller in _controllers.values) {
        controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.template.name} QR Code',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.template.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_generatedData != null) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.template.color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _generatedData!,
                      size: 200,
                      version: QrVersions.auto,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ...widget.template.fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _controllers[field.key],
                    keyboardType: field.keyboardType,
                    decoration: InputDecoration(
                      labelText: field.isOptional 
                          ? '${field.label} (Optional)'
                          : field.label,
                      hintText: field.hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        widget.template.icon,
                        color: widget.template.color,
                      ),
                    ),
                    validator: (value) {
                      if (!field.isOptional && (value == null || value.isEmpty)) {
                        return 'Please enter ${field.label.toLowerCase()}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _generateQrCode,
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.template.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_generatedData != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
