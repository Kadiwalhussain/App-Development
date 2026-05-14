import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_code_scanner/services/history_service.dart';

/// Regular expression pattern for validating email addresses
final RegExp _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

/// Regular expression pattern for validating phone numbers
final RegExp _phonePattern = RegExp(r'^\+?[\d\s-]{10,}$');

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> with SingleTickerProviderStateMixin {
  String qrResult = 'Scanned Data Will Appear Here';
  bool _hasScanned = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isUrl => qrResult.startsWith('http://') || qrResult.startsWith('https://');
  
  bool get _isEmail => qrResult.startsWith('mailto:') || 
      _emailPattern.hasMatch(qrResult);
  
  bool get _isPhone => qrResult.startsWith('tel:') || 
      _phonePattern.hasMatch(qrResult);

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#2196F3',
        'Cancel',
        true,
        ScanMode.QR,
      );
      
      if (!mounted) return;
      
      if (qrCode != '-1') {
        setState(() {
          qrResult = qrCode;
          _hasScanned = true;
        });
        _animationController.forward(from: 0);
        // Save to history
        await HistoryService.addToHistory(qrCode, true);
      }
    } on PlatformException {
      setState(() {
        qrResult = 'Failed to scan QR Code';
        _hasScanned = true;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (!_hasScanned) return;
    await Clipboard.setData(ClipboardData(text: qrResult));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Copied to clipboard'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _launchUrl() async {
    String urlString = qrResult;
    
    // Handle different URL types
    if (_isEmail && !qrResult.startsWith('mailto:')) {
      urlString = 'mailto:$qrResult';
    } else if (_isPhone && !qrResult.startsWith('tel:')) {
      urlString = 'tel:$qrResult';
    }
    
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open this link'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _getContentType() {
    if (_isUrl) return 'URL';
    if (_isEmail) return 'Email';
    if (_isPhone) return 'Phone';
    if (qrResult.startsWith('WIFI:')) return 'WiFi';
    if (qrResult.startsWith('BEGIN:VCARD')) return 'Contact';
    if (qrResult.startsWith('geo:')) return 'Location';
    return 'Text';
  }

  IconData _getContentIcon() {
    if (_isUrl) return Icons.link;
    if (_isEmail) return Icons.email;
    if (_isPhone) return Icons.phone;
    if (qrResult.startsWith('WIFI:')) return Icons.wifi;
    if (qrResult.startsWith('BEGIN:VCARD')) return Icons.contact_page;
    if (qrResult.startsWith('geo:')) return Icons.location_on;
    return Icons.text_fields;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Scan button with animation
                ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 1).animate(_scaleAnimation),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue, Colors.blueAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(75),
                        onTap: scanQR,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner, size: 50, color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'Tap to Scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Result section
                if (_hasScanned) ...[
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getContentIcon(),
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getContentType(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SelectableText(
                                qrResult,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isUrl || _isEmail || _isPhone 
                                      ? Colors.blue 
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Action buttons
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                _ActionButton(
                                  icon: Icons.copy,
                                  label: 'Copy',
                                  color: Colors.blue,
                                  onTap: _copyToClipboard,
                                ),
                                if (_isUrl || _isEmail || _isPhone)
                                  _ActionButton(
                                    icon: Icons.open_in_new,
                                    label: 'Open',
                                    color: Colors.green,
                                    onTap: _launchUrl,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Initial state hint
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scan Result',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the button above to scan a QR code',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
