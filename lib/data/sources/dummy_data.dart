import 'package:lms_mobile_app/data/models/course.dart';
import 'package:lms_mobile_app/data/models/lesson.dart';

class DummyData {
  static List<Course> getCourses() {
    return [
      Course(
        id: '1',
        title: 'Accounting',
        description:
            'Learn the fundamentals of accounting and bookkeeping principles.',
        instructor: 'Pak Bayu',
        color: '#A29BFE',
        icon: '📊',
        chaptersCount: 3,
        duration: '8 hours',
        lessons: [
          Lesson(
            id: '1-1',
            courseId: '1',
            title: 'Introduction to Accounting',
            content:
                'Learn the basic concepts and principles of accounting. Understand the fundamental equation and how to record transactions.',
            duration: '45 min',
          ),
          Lesson(
            id: '1-2',
            courseId: '1',
            title: 'Double Entry System',
            content:
                'Master the double entry bookkeeping system. Learn how to debit and credit accounts properly.',
            duration: '50 min',
          ),
          Lesson(
            id: '1-3',
            courseId: '1',
            title: 'Financial Statements',
            content:
                'Understand how to prepare and interpret financial statements including balance sheet and income statement.',
            duration: '55 min',
          ),
          Lesson(
            id: '1-4',
            courseId: '1',
            title: 'Accounting Ethics',
            content:
                'Explore the ethical standards and practices in professional accounting.',
            duration: '40 min',
          ),
        ],
      ),
      Course(
        id: '2',
        title: 'Agriculture',
        description:
            'Discover modern farming techniques and sustainable agriculture practices.',
        instructor: 'Pak Budi',
        color: '#74B9FF',
        icon: '🌾',
        chaptersCount: 4,
        duration: '10 hours',
        lessons: [
          Lesson(
            id: '2-1',
            courseId: '2',
            title: 'Soil Science Basics',
            content:
                'Understand soil composition, pH levels, and nutrient management for optimal crop growth.',
            duration: '50 min',
          ),
          Lesson(
            id: '2-2',
            courseId: '2',
            title: 'Crop Management',
            content:
                'Learn about crop rotation, pest control, and modern farming techniques.',
            duration: '55 min',
          ),
          Lesson(
            id: '2-3',
            courseId: '2',
            title: 'Irrigation Systems',
            content:
                'Explore different irrigation methods and water management strategies.',
            duration: '45 min',
          ),
          Lesson(
            id: '2-4',
            courseId: '2',
            title: 'Sustainable Farming',
            content:
                'Discover eco-friendly practices and sustainable agriculture for the future.',
            duration: '60 min',
          ),
        ],
      ),
      Course(
        id: '3',
        title: 'Economics',
        description:
            'Understand macroeconomic and microeconomic concepts that shape the world.',
        instructor: 'Bu Mega',
        color: '#FF7675',
        icon: '📈',
        chaptersCount: 3,
        duration: '7 hours',
        lessons: [
          Lesson(
            id: '3-1',
            courseId: '3',
            title: 'Microeconomics Fundamentals',
            content:
                'Learn about supply and demand, consumer behavior, and market structures.',
            duration: '50 min',
          ),
          Lesson(
            id: '3-2',
            courseId: '3',
            title: 'Macroeconomics Overview',
            content:
                'Understand GDP, inflation, unemployment, and monetary policy.',
            duration: '55 min',
          ),
          Lesson(
            id: '3-3',
            courseId: '3',
            title: 'International Trade',
            content:
                'Explore global trade, exchange rates, and trade policies.',
            duration: '48 min',
          ),
          Lesson(
            id: '3-4',
            courseId: '3',
            title: 'Economic Development',
            content:
                'Study economic development theories and growth strategies for emerging markets.',
            duration: '52 min',
          ),
        ],
      ),
      Course(
        id: '4',
        title: 'Art & Design',
        description:
            'Master the principles of visual arts and modern design thinking.',
        instructor: 'Pak Arif',
        color: '#FFBE76',
        icon: '🎨',
        chaptersCount: 3,
        duration: '9 hours',
        lessons: [
          Lesson(
            id: '4-1',
            courseId: '4',
            title: 'Design Principles',
            content:
                'Learn about color theory, composition, and visual hierarchy in design.',
            duration: '60 min',
          ),
          Lesson(
            id: '4-2',
            courseId: '4',
            title: 'Digital Art Basics',
            content:
                'Get started with digital painting and illustration techniques.',
            duration: '65 min',
          ),
          Lesson(
            id: '4-3',
            courseId: '4',
            title: 'User Interface Design',
            content: 'Explore UI/UX principles and modern design patterns.',
            duration: '55 min',
          ),
          Lesson(
            id: '4-4',
            courseId: '4',
            title: 'Typography & Branding',
            content: 'Master typography and create cohesive brand identities.',
            duration: '50 min',
          ),
        ],
      ),
      Course(
        id: '5',
        title: 'Biology',
        description:
            'Explore the fascinating world of living organisms and life sciences.',
        instructor: 'Pak Andi',
        color: '#00B894',
        icon: '🧬',
        chaptersCount: 4,
        duration: '11 hours',
        lessons: [
          Lesson(
            id: '5-1',
            courseId: '5',
            title: 'Cell Biology',
            content:
                'Understand cell structure, function, and reproduction mechanisms.',
            duration: '55 min',
          ),
          Lesson(
            id: '5-2',
            courseId: '5',
            title: 'Genetics Essentials',
            content:
                'Learn about DNA, genes, inheritance, and genetic variation.',
            duration: '60 min',
          ),
          Lesson(
            id: '5-3',
            courseId: '5',
            title: 'Evolution & Natural Selection',
            content:
                'Explore evolutionary theory and the mechanisms of natural selection.',
            duration: '50 min',
          ),
          Lesson(
            id: '5-4',
            courseId: '5',
            title: 'Ecology & Ecosystems',
            content:
                'Understand ecosystems, food chains, and conservation biology.',
            duration: '58 min',
          ),
        ],
      ),
      Course(
        id: '6',
        title: 'Philosophy',
        description:
            'Engage with fundamental philosophical questions and ideas.',
        instructor: 'Pak James',
        color: '#6C5CE7',
        icon: '🤔',
        chaptersCount: 3,
        duration: '8 hours',
        lessons: [
          Lesson(
            id: '6-1',
            courseId: '6',
            title: 'Ethics & Morality',
            content:
                'Explore ethical theories and moral philosophy across cultures.',
            duration: '50 min',
          ),
          Lesson(
            id: '6-2',
            courseId: '6',
            title: 'Epistemology',
            content:
                'Understand knowledge, truth, and the limits of human understanding.',
            duration: '52 min',
          ),
          Lesson(
            id: '6-3',
            courseId: '6',
            title: 'Metaphysics',
            content: 'Study the nature of reality, existence, and being.',
            duration: '54 min',
          ),
          Lesson(
            id: '6-4',
            courseId: '6',
            title: 'Political Philosophy',
            content: 'Explore theories of justice, rights, and government.',
            duration: '56 min',
          ),
        ],
      ),
    ];
  }
}
