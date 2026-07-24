import '../../core/services/career_data_service.dart';
import '../quiz/quiz_session.dart';
import '../results/recommendation_result.dart';
import 'roadmap_plan.dart';

class RoadmapEngine {
  RoadmapEngine._();

  static Future<RoadmapPlan> generate({
    required QuizSession session,
    required CareerRecommendation recommendation,
  }) async {
    final currentYear = DateTime.now().year;
    final answeredSkills = {
      for (final answer in session.answers) answer.answerId,
    };
    final template = _templates[recommendation.id] ?? _defaultTemplate;
    final data = await CareerDataService.load();
    final career = data.byId(recommendation.id);

    return RoadmapPlan(
      careerTitle: recommendation.title,
      mascotAsset: recommendation.mascotAsset,
      years: [
        RoadmapYear(
          label: 'Year 1\n($currentYear)',
          title: 'Build Foundations',
          progress: 80,
          milestones: template.yearOne,
        ),
        RoadmapYear(
          label: 'Year 2',
          title: 'Develop Core Skills',
          progress: 60,
          milestones: template.yearTwo,
        ),
        RoadmapYear(
          label: 'Year 3',
          title: 'Hands-on Experience',
          progress: 30,
          milestones: template.yearThree,
        ),
        RoadmapYear(
          label: 'First Job',
          title: recommendation.title,
          progress: 0,
          milestones: [
            'Apply for entry-level ${recommendation.title} roles',
            'Target salary: ${recommendation.salaryRange}',
            if (career != null)
              'Look at: ${career.topEmployers.take(3).join(', ')}',
          ],
        ),
      ],
      skillGaps: template.skillGaps.map((gap) {
        if (_isAlreadyCovered(gap.skill, answeredSkills)) {
          return SkillGap(
            skill: gap.skill,
            priority: 'You are doing great',
            action: 'Keep practicing through portfolio work',
          );
        }
        return gap;
      }).toList(),
    );
  }

  static bool _isAlreadyCovered(String skill, Set<String> answeredSkills) {
    final normalized = skill.toLowerCase();
    if (normalized.contains('communication')) {
      return answeredSkills.contains('communication') ||
          answeredSkills.contains('helping_people');
    }
    if (normalized.contains('excel') || normalized.contains('dashboard')) {
      return answeredSkills.contains('excel_reporting') ||
          answeredSkills.contains('data_insights');
    }
    if (normalized.contains('process')) {
      return answeredSkills.contains('process_mapping');
    }
    if (normalized.contains('sql') || normalized.contains('data')) {
      return answeredSkills.contains('data_insights') ||
          answeredSkills.contains('problem_solving');
    }
    if (normalized.contains('agile') || normalized.contains('scrum')) {
      return answeredSkills.contains('leading_projects');
    }
    if (normalized.contains('stakeholder')) {
      return answeredSkills.contains('communication') ||
          answeredSkills.contains('helping_people');
    }
    if (normalized.contains('design') || normalized.contains('figma')) {
      return answeredSkills.contains('designing_visuals') ||
          answeredSkills.contains('creative_thinking');
    }
    return false;
  }
}

class _RoadmapTemplate {
  final List<String> yearOne;
  final List<String> yearTwo;
  final List<String> yearThree;
  final List<SkillGap> skillGaps;

  const _RoadmapTemplate({
    required this.yearOne,
    required this.yearTwo,
    required this.yearThree,
    required this.skillGaps,
  });
}

const _templates = <String, _RoadmapTemplate>{
  'service_manager': _RoadmapTemplate(
    yearOne: [
      'Basic Business Skills',
      'Communication',
      'MS Office and tools',
    ],
    yearTwo: [
      'Project Management',
      'People Management',
      'Data Analysis',
    ],
    yearThree: [
      'Lead small projects',
      'Stakeholder management',
      'Performance tracking',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Stakeholder Management',
        priority: 'High Priority',
        action: 'Practice meeting notes, updates, and escalation plans',
      ),
      SkillGap(
        skill: 'Advanced Excel',
        priority: 'High Priority',
        action: 'Build KPI dashboards and service reports',
      ),
      SkillGap(
        skill: 'ITIL / Service Basics',
        priority: 'Medium Priority',
        action: 'Study incident, change, and service request workflows',
      ),
      SkillGap(
        skill: 'Public Speaking',
        priority: 'Low Priority',
        action: 'Present one project update per month',
      ),
    ],
  ),
  'business_analyst': _RoadmapTemplate(
    yearOne: [
      'Business process basics',
      'Requirements writing',
      'Spreadsheet analysis',
    ],
    yearTwo: [
      'Dashboard building',
      'User stories and acceptance criteria',
      'Stakeholder interviews',
    ],
    yearThree: [
      'Capstone case study',
      'Internship or client project',
      'Portfolio documentation',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Requirements Analysis',
        priority: 'High Priority',
        action: 'Write sample BRDs and user stories',
      ),
      SkillGap(
        skill: 'Excel and Dashboards',
        priority: 'High Priority',
        action: 'Create dashboards from public datasets',
      ),
      SkillGap(
        skill: 'Process Mapping',
        priority: 'Medium Priority',
        action: 'Map current and improved workflows',
      ),
      SkillGap(
        skill: 'SQL Basics',
        priority: 'Medium Priority',
        action: 'Practice SELECT, JOIN, GROUP BY, and filters',
      ),
    ],
  ),
  'data_analyst': _RoadmapTemplate(
    yearOne: [
      'Statistics basics',
      'Excel analysis',
      'Data storytelling',
    ],
    yearTwo: [
      'SQL fundamentals',
      'Dashboard tools',
      'Data cleaning workflow',
    ],
    yearThree: [
      'Portfolio with 3 case studies',
      'Internship applications',
      'Interview practice',
    ],
    skillGaps: [
      SkillGap(
        skill: 'SQL Basics',
        priority: 'High Priority',
        action: 'Analyze sample sales and hiring datasets',
      ),
      SkillGap(
        skill: 'Dashboard Design',
        priority: 'High Priority',
        action: 'Build Power BI or Looker Studio dashboards',
      ),
      SkillGap(
        skill: 'Data Cleaning',
        priority: 'Medium Priority',
        action: 'Practice fixing missing, duplicate, and messy data',
      ),
      SkillGap(
        skill: 'Presentation Skills',
        priority: 'Low Priority',
        action: 'Explain each dashboard in a short written insight',
      ),
    ],
  ),
  'project_manager': _RoadmapTemplate(
    yearOne: [
      'Project planning basics',
      'Communication fundamentals',
      'Documentation standards',
    ],
    yearTwo: [
      'Agile/Scrum fundamentals',
      'Risk management',
      'Budget tracking',
    ],
    yearThree: [
      'Lead a team project',
      'Stakeholder presentations',
      'PMP or CAPM prep',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Agile/Scrum',
        priority: 'High Priority',
        action: 'Get hands-on with sprint planning and retrospectives',
      ),
      SkillGap(
        skill: 'Stakeholder Communication',
        priority: 'High Priority',
        action: 'Practice status reporting and escalation',
      ),
      SkillGap(
        skill: 'Risk Management',
        priority: 'Medium Priority',
        action: 'Create risk registers for sample projects',
      ),
      SkillGap(
        skill: 'MS Project / Jira',
        priority: 'Medium Priority',
        action: 'Learn project tracking with real tools',
      ),
    ],
  ),
  'systems_analyst': _RoadmapTemplate(
    yearOne: [
      'Systems documentation',
      'SQL basics',
      'SDLC fundamentals',
    ],
    yearTwo: [
      'Requirements gathering',
      'Process mapping',
      'System testing basics',
    ],
    yearThree: [
      'Case study: system improvement',
      'Stakeholder workshops',
      'Portfolio of documentation',
    ],
    skillGaps: [
      SkillGap(
        skill: 'SQL',
        priority: 'High Priority',
        action: 'Write complex queries with JOINs and subqueries',
      ),
      SkillGap(
        skill: 'Requirements Documentation',
        priority: 'High Priority',
        action: 'Create BRDs and functional specs',
      ),
      SkillGap(
        skill: 'Process Mapping',
        priority: 'Medium Priority',
        action: 'Use BPMN or flowcharts to document workflows',
      ),
    ],
  ),
  'ux_designer': _RoadmapTemplate(
    yearOne: [
      'Design fundamentals',
      'Figma basics',
      'User research methods',
    ],
    yearTwo: [
      'Wireframing and prototyping',
      'Usability testing',
      'Portfolio case study 1',
    ],
    yearThree: [
      'Interaction design',
      'Design systems',
      'Portfolio case study 2-3',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Figma',
        priority: 'High Priority',
        action: 'Recreate 3 popular app screens in Figma',
      ),
      SkillGap(
        skill: 'User Research',
        priority: 'High Priority',
        action: 'Conduct 2 usability tests and document findings',
      ),
      SkillGap(
        skill: 'Visual Design',
        priority: 'Medium Priority',
        action: 'Study typography, color theory, and layout',
      ),
    ],
  ),
  'data_scientist': _RoadmapTemplate(
    yearOne: [
      'Python fundamentals',
      'Statistics review',
      'Exploratory data analysis',
    ],
    yearTwo: [
      'Machine learning basics',
      'SQL for data science',
      'Data visualization',
    ],
    yearThree: [
      'ML case study project',
      'Kaggle competitions',
      'Portfolio with 3 projects',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Python for Data Science',
        priority: 'High Priority',
        action: 'Complete pandas, numpy, and scikit-learn tutorials',
      ),
      SkillGap(
        skill: 'Machine Learning',
        priority: 'High Priority',
        action: 'Build and evaluate 3 ML models on real datasets',
      ),
      SkillGap(
        skill: 'Statistics',
        priority: 'Medium Priority',
        action: 'Review probability, hypothesis testing, and regression',
      ),
    ],
  ),
  'scrum_master': _RoadmapTemplate(
    yearOne: [
      'Agile fundamentals',
      'Scrum framework',
      'Team facilitation basics',
    ],
    yearTwo: [
      'Jira administration',
      'Conflict resolution',
      'Sprint planning & retros',
    ],
    yearThree: [
      'Lead Scrum ceremonies',
      'Coaching techniques',
      'CSM certification prep',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Scrum Facilitation',
        priority: 'High Priority',
        action: 'Practice facilitating sprint ceremonies',
      ),
      SkillGap(
        skill: 'Conflict Resolution',
        priority: 'High Priority',
        action: 'Study team dynamics and mediation techniques',
      ),
      SkillGap(
        skill: 'Jira',
        priority: 'Medium Priority',
        action: 'Learn Jira workflows and board administration',
      ),
    ],
  ),
  'product_owner': _RoadmapTemplate(
    yearOne: [
      'Product thinking',
      'User story writing',
      'Backlog management',
    ],
    yearTwo: [
      'Stakeholder prioritization',
      'Roadmapping',
      'Customer research',
    ],
    yearThree: [
      'Own a product feature',
      'A/B testing basics',
      'CSPO certification prep',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Backlog Management',
        priority: 'High Priority',
        action: 'Prioritize and maintain a sample product backlog',
      ),
      SkillGap(
        skill: 'Stakeholder Prioritization',
        priority: 'High Priority',
        action: 'Practice negotiating priorities across stakeholders',
      ),
      SkillGap(
        skill: 'User Story Writing',
        priority: 'Medium Priority',
        action: 'Write acceptance criteria for 10 user stories',
      ),
    ],
  ),
  'qa_analyst': _RoadmapTemplate(
    yearOne: [
      'Manual testing fundamentals',
      'Bug reporting',
      'Test case writing',
    ],
    yearTwo: [
      'Test planning',
      'Basic SQL for testing',
      'Automation concepts',
    ],
    yearThree: [
      'Automation tools (Selenium)',
      'API testing',
      'ISTQB certification prep',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Test Case Design',
        priority: 'High Priority',
        action: 'Write 20 test cases for a sample application',
      ),
      SkillGap(
        skill: 'SQL for Testers',
        priority: 'High Priority',
        action: 'Practice data validation queries',
      ),
      SkillGap(
        skill: 'Test Automation',
        priority: 'Medium Priority',
        action: 'Write 5 automated test scripts',
      ),
    ],
  ),
  'it_auditor': _RoadmapTemplate(
    yearOne: [
      'Risk assessment basics',
      'Internal controls',
      'Data privacy (RA 10173)',
    ],
    yearTwo: [
      'Audit documentation',
      'ISO 27001 fundamentals',
      'Control testing',
    ],
    yearThree: [
      'Audit engagement support',
      'Remediation tracking',
      'CISA certification prep',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Risk Assessment',
        priority: 'High Priority',
        action: 'Create a risk register for a sample IT environment',
      ),
      SkillGap(
        skill: 'Audit Documentation',
        priority: 'High Priority',
        action: 'Write audit work papers and findings',
      ),
      SkillGap(
        skill: 'Data Privacy (RA 10173)',
        priority: 'Medium Priority',
        action: 'Study the PH Data Privacy Act requirements',
      ),
    ],
  ),
  'cybersecurity_analyst': _RoadmapTemplate(
    yearOne: [
      'Networking fundamentals',
      'Security basics',
      'CompTIA Security+ prep',
    ],
    yearTwo: [
      'SIEM tools',
      'Incident response',
      'Threat intelligence',
    ],
    yearThree: [
      'SOC simulation',
      'Vulnerability assessment',
      'Portfolio of security cases',
    ],
    skillGaps: [
      SkillGap(
        skill: 'Network Security',
        priority: 'High Priority',
        action: 'Learn TCP/IP, firewalls, and network topologies',
      ),
      SkillGap(
        skill: 'Incident Response',
        priority: 'High Priority',
        action: 'Practice triage and escalation procedures',
      ),
      SkillGap(
        skill: 'SIEM Tools',
        priority: 'Medium Priority',
        action: 'Explore Splunk or Wazuh for log analysis',
      ),
    ],
  ),
  'erp_consultant': _RoadmapTemplate(
    yearOne: [
      'ERP fundamentals',
      'Business process mapping',
      'Client communication',
    ],
    yearTwo: [
      'ERP configuration basics',
      'Requirements analysis',
      'Project documentation',
    ],
    yearThree: [
      'Implementation project support',
      'User training',
      'Vendor certification prep',
    ],
    skillGaps: [
      SkillGap(
        skill: 'ERP Configuration',
        priority: 'High Priority',
        action: 'Learn SAP or Oracle module basics',
      ),
      SkillGap(
        skill: 'Process Mapping',
        priority: 'High Priority',
        action: 'Document business processes for a sample company',
      ),
      SkillGap(
        skill: 'Client Training',
        priority: 'Medium Priority',
        action: 'Prepare a training deck for end users',
      ),
    ],
  ),
};

const _defaultTemplate = _RoadmapTemplate(
  yearOne: [
    'Career foundations',
    'Communication',
    'Basic tools and documentation',
  ],
  yearTwo: [
    'Core technical skills',
    'Guided projects',
    'Portfolio building',
  ],
  yearThree: [
    'Internship applications',
    'Interview preparation',
    'Capstone project',
  ],
  skillGaps: [
    SkillGap(
      skill: 'Portfolio Building',
      priority: 'High Priority',
      action: 'Create 2-3 documented school or personal projects',
    ),
    SkillGap(
      skill: 'Communication',
      priority: 'Medium Priority',
      action: 'Practice explaining technical work simply',
    ),
    SkillGap(
      skill: 'Career Research',
      priority: 'Medium Priority',
      action: 'Compare job posts and list repeated skills',
    ),
  ],
);
