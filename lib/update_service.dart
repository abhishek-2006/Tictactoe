import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pub_semver/pub_semver.dart';

class UpdateService {
  static const String _owner = "abhishek-2006";
  static const String _repo = "Tictactoe";
  static const String _apiUrl = "https://api.github.com/repos/$_owner/$_repo/releases/latest";

  static Future<void> check(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final String latestTag = data['tag_name'].toString().replaceAll('v', '');
      final List assets = data['assets'];

      // Filter for the APK asset
      final apkAsset = assets.firstWhere(
            (a) => a['name'].toString().endsWith('.apk'),
        orElse: () => null,
      );

      if (apkAsset == null) return;

      const String downloadUrl = "https://abhishekshah-portfolio.vercel.app/tictactoe";
      final String releaseNotes = data['body'] ?? "Bug fixes and performance improvements.";

      // Compare versions
      final PackageInfo info = await PackageInfo.fromPlatform();
      final Version current = Version.parse(info.version);
      final Version latest = Version.parse(latestTag);

      if (latest > current) {
        if (!context.mounted) return;
        _showDialog(context, latestTag, downloadUrl, releaseNotes);
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  static void _showDialog(BuildContext context, String ver, String url, String notes) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Responsive sizing for small screens (e.g., 5.5 inch devices)
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360 || size.height < 600;

    showDialog(
      context: context,
      barrierDismissible: false, // Force update if preferred
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24, vertical: 8),
        title: Row(
          children: [
            Image.asset('assets/splash.png', width: isSmallScreen ? 24 : 32, height: isSmallScreen ? 24 : 32),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Text(
                "Update Found",
                style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Version $ver is now available.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text("Release Notes:", style: TextStyle(fontSize: isSmallScreen ? 11 : 12, color: Colors.blueAccent)),
              const SizedBox(height: 4),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(notes, style: TextStyle(fontSize: isSmallScreen ? 12 : 13)),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Later", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: isSmallScreen ? 12 : 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 8 : 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text("Download APK", style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
          ),
        ],
      ),
    );
  }
}