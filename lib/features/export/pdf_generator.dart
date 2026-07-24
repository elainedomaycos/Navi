import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

import '../quiz/quiz_session.dart';
import '../results/recommendation_result.dart';
import '../roadmap/roadmap_plan.dart';

class PdfExportGenerator {
  PdfExportGenerator._();

  static const _primary = PdfColor(0.24, 0.21, 0.50);
  static const _primaryPale = PdfColor(0.88, 0.86, 0.96);
  static const _textDark = PdfColor(0.17, 0.15, 0.38);
  static const _textMid = PdfColor(0.49, 0.43, 0.69);
  static const _textMuted = PdfColor(0.69, 0.66, 0.78);
  static const _matchHigh = PdfColor(0.30, 0.69, 0.31);
  static const _border = PdfColor(0.90, 0.87, 0.97);
  static const _white = PdfColors.white;
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
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NAVI',
                  style: pw.TextStyle(
                    font: _nunito,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: _white,
                    letterSpacing: 3,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Career Assessment Report',
                  style: pw.TextStyle(
                    font: _nunito,
                    fontSize: 11,
                    color: _primaryPale,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              color: PdfColor(0.30, 0.69, 0.31, 0.16),
              borderRadius: pw.BorderRadius.circular(100),
            ),
            child: pw.Text(
              '${match.confidence}% Match',
              style: pw.TextStyle(
                font: _nunito,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _matchHigh,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCareerMatch(CareerRecommendation match) {
    return _card(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Career Match'),
          pw.SizedBox(height: 8),
          pw.Text(
            match.title,
            style: pw.TextStyle(
              font: _nunito,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _textDark,
            ),
          ),
          pw.SizedBox(height: 8),
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
            pw.SizedBox(height: 10),
            ...match.reasons.map(
              (r) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '- ',
                      style: pw.TextStyle(
                        font: _nunito,
                        fontSize: 10,
                        color: _textDark,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        r,
                        style: pw.TextStyle(
                          font: _nunito,
                          fontSize: 10,
                          color: _textDark,
                          lineSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildRoadmap(RoadmapPlan roadmap) {
    return _card(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Roadmap'),
          pw.SizedBox(height: 10),
          ...roadmap.years.asMap().entries.map((entry) {
            final i = entry.key;
            final year = entry.value;
            final isLast = i == roadmap.years.length - 1;
            return pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 52,
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: 18,
                        height: 18,
                        decoration: pw.BoxDecoration(
                          color: _primary,
                          shape: pw.BoxShape.circle,
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          '${i + 1}',
                          style: pw.TextStyle(
                            font: _nunito,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: _white,
                          ),
                        ),
                      ),
                      if (!isLast)
                        pw.Container(
                          width: 1.5,
                          height: 40,
                          color: _primaryPale,
                        ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          year.label.replaceAll('\n', ' '),
                          style: pw.TextStyle(
                            font: _nunito,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _textMid,
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
                        pw.SizedBox(height: 4),
                        ...year.milestones.map(
                          (m) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Text(
                              '- $m',
                              style: pw.TextStyle(
                                font: _nunito,
                                fontSize: 9,
                                color: _textDark,
                                lineSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildSkillsToLearn(RoadmapPlan roadmap) {
    if (roadmap.skillGaps.isEmpty) return pw.SizedBox.shrink();
    return _card(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Skills to Learn'),
          pw.SizedBox(height: 10),
          ...roadmap.skillGaps.map(
            (gap) => pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(bottom: 6),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor(0.96, 0.95, 1.0),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          gap.skill,
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
                  pw.SizedBox(width: 8),
                  _priorityBadge(gap.priority),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSalary(CareerRecommendation match) {
    return _card(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Salary & Demand'),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text(
                match.salaryRange,
                style: pw.TextStyle(
                  font: _nunito,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
              pw.SizedBox(width: 12),
              _infoChip('Trend: ${match.trend}'),
              pw.SizedBox(width: 6),
              _infoChip('Demand: ${match.demand}'),
            ],
          ),
          if (match.topEmployers.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Top Employers',
              style: pw.TextStyle(
                font: _nunito,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Wrap(
              spacing: 6,
              runSpacing: 4,
              children: match.topEmployers
                  .map((e) => _infoChip(e))
                  .toList(),
            ),
          ],
        ],
      ),
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

  static pw.Widget _card({required pw.Widget child}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      child: child,
    );
  }

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

  static pw.Widget _priorityBadge(String priority) {
    final label = priority.replaceAll(' Priority', '');
    final color = switch (priority) {
      'High Priority' => PdfColor(0.94, 0.60, 0.60),
      'Medium Priority' => PdfColor(1.0, 0.84, 0.31),
      _ => PdfColor(0.30, 0.69, 0.31),
    };
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.18),
        borderRadius: pw.BorderRadius.circular(100),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          font: _nunito,
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _infoChip(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: _primaryPale,
        borderRadius: pw.BorderRadius.circular(100),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: _nunito,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: _primary,
        ),
      ),
    );
  }
}
