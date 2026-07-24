import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

import '../quiz/quiz_session.dart';
import '../results/recommendation_result.dart';
import '../roadmap/roadmap_plan.dart';

class PdfExportGenerator {
  PdfExportGenerator._();

  static const _primary = PdfColor(0.24, 0.21, 0.50);
  static const _textDark = PdfColor(0.17, 0.15, 0.38);
  static const _textMid = PdfColor(0.49, 0.43, 0.69);
  static const _textMuted = PdfColor(0.69, 0.66, 0.78);
  static const _border = PdfColor(0.90, 0.87, 0.97);
  static pw.Font? _nunito;

  static Future<pw.Document> generate({
    required CareerRecommendation match,
    required RoadmapPlan roadmap,
    required QuizSession session,
  }) async {
    final doc = pw.Document();
    _nunito ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/Nunito-Regular.ttf'),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(595.28, 841.89),
        margin: const pw.EdgeInsets.fromLTRB(24, 20, 24, 24),
        build: (context) => [
          _buildHeader(match),
          pw.SizedBox(height: 16),
          _buildCareerMatch(match),
          pw.SizedBox(height: 14),
          _buildRoadmap(roadmap),
          pw.SizedBox(height: 14),
          _buildSkillsToLearn(roadmap),
          pw.SizedBox(height: 14),
          _buildSalary(match),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    return doc;
  }

  // ── Sections ───────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(CareerRecommendation match) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'NAVI',
          style: pw.TextStyle(
            font: _nunito,
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: _primary,
            letterSpacing: 3,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Career Assessment Report',
          style: pw.TextStyle(
            font: _nunito,
            fontSize: 11,
            color: _textMid,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Match: ${match.confidence}%',
          style: pw.TextStyle(
            font: _nunito,
            fontSize: 10,
            color: _textMuted,
          ),
        ),
        pw.Divider(color: _border, thickness: 0.5),
      ],
    );
  }

  static pw.Widget _buildCareerMatch(CareerRecommendation match) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Career Match'),
        pw.SizedBox(height: 6),
        pw.Text(
          match.title,
          style: pw.TextStyle(
            font: _nunito,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: _textDark,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          match.summary,
          style: pw.TextStyle(
            font: _nunito,
            fontSize: 10,
            color: _textDark,
            lineSpacing: 4,
          ),
        ),
        if (match.reasons.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          ...match.reasons.map(
            (r) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                '- $r',
                style: pw.TextStyle(
                  font: _nunito,
                  fontSize: 10,
                  color: _textDark,
                  lineSpacing: 3,
                ),
              ),
            ),
          ),
        ],
        pw.Divider(color: _border, thickness: 0.5),
      ],
    );
  }

  static pw.Widget _buildRoadmap(RoadmapPlan roadmap) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Roadmap'),
        pw.SizedBox(height: 8),
        ...roadmap.years.asMap().entries.map((entry) {
          final i = entry.key;
          final year = entry.value;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${i + 1}. ${year.label.replaceAll('\n', ' ')}',
                style: pw.TextStyle(
                  font: _nunito,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                year.title,
                style: pw.TextStyle(
                  font: _nunito,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
              pw.SizedBox(height: 3),
              ...year.milestones.map(
                (m) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    '  - $m',
                    style: pw.TextStyle(
                      font: _nunito,
                      fontSize: 9,
                      color: _textDark,
                      lineSpacing: 3,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
            ],
          );
        }),
        pw.Divider(color: _border, thickness: 0.5),
      ],
    );
  }

  static pw.Widget _buildSkillsToLearn(RoadmapPlan roadmap) {
    if (roadmap.skillGaps.isEmpty) return pw.SizedBox.shrink();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Skills to Learn'),
        pw.SizedBox(height: 8),
        ...roadmap.skillGaps.map(
          (gap) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${gap.skill}  [${gap.priority.replaceAll(' Priority', '')}]',
                  style: pw.TextStyle(
                    font: _nunito,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  gap.action,
                  style: pw.TextStyle(
                    font: _nunito,
                    fontSize: 9,
                    color: _textMid,
                    lineSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.Divider(color: _border, thickness: 0.5),
      ],
    );
  }

  static pw.Widget _buildSalary(CareerRecommendation match) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Salary & Demand'),
        pw.SizedBox(height: 6),
        pw.Text(
          'Range: ${match.salaryRange}',
          style: pw.TextStyle(
            font: _nunito,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _textDark,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'Trend: ${match.trend}  |  Demand: ${match.demand}',
          style: pw.TextStyle(
            font: _nunito,
            fontSize: 9,
            color: _textMid,
          ),
        ),
        if (match.topEmployers.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            'Top Employers',
            style: pw.TextStyle(
              font: _nunito,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _textDark,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            match.topEmployers.join(', '),
            style: pw.TextStyle(
              font: _nunito,
              fontSize: 9,
              color: _textMid,
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'Generated by ',
            style: pw.TextStyle(font: _nunito, fontSize: 8, color: _textMuted),
          ),
          pw.Text(
            'Navi',
            style: pw.TextStyle(
              font: _nunito,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        font: _nunito,
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: _primary,
      ),
    );
  }
}
