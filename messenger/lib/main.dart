import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MessengerApp());
}

// ─── Theme & Constants ────────────────────────────────────────────────────────

const _bg = Color(0xFF0D0F14);
const _surface = Color(0xFF161B24);
const _surfaceAlt = Color(0xFF1E2535);
const _accent = Color(0xFF4F8EF7);
const _accentSoft = Color(0xFF2A3F6F);
const _green = Color(0xFF3DD68C);
const _textPrimary = Color(0xFFF0F2F8);
const _textSecondary = Color(0xFF8892A4);
const _divider = Color(0xFF232B3B);

// ─── App Root ─────────────────────────────────────────────────────────────────

class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          primary: _accent,
          surface: _surface,
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ─── Main Shell with Bottom Nav ───────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navAnim;

  final _screens = const [
    ConversationsScreen(),
    PeopleScreen(),
    DiscoverScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _navAnim.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _navAnim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chats', 10),
      (Icons.people_rounded, Icons.people_outline_rounded, 'People', 0),
      (Icons.explore_rounded, Icons.explore_outlined, 'Discover', 0),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? _accent.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                selected ? item.$1 : item.$2,
                                color: selected ? _accent : _textSecondary,
                                size: 22,
                              ),
                            ),
                            if (item.$4 > 0)
                              Positioned(
                                right: 8,
                                top: 2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _surface, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.$4}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected ? _accent : _textSecondary,
                          ),
                          child: Text(item.$3),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class Conversation {
  final String id;
  final String name;
  final String avatarInitials;
  final Color avatarColor;
  final String lastMessage;
  final String time;
  final int unread;
  final bool online;
  final bool isGroup;

  const Conversation({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.avatarColor,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.online = false,
    this.isGroup = false,
  });
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final MessageStatus status;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.read,
  });
}

class Person {
  final String name;
  final String username;
  final String avatarInitials;
  final Color avatarColor;
  final bool online;
  final bool isFollowing;
  final int mutualFriends;

  const Person({
    required this.name,
    required this.username,
    required this.avatarInitials,
    required this.avatarColor,
    this.online = false,
    this.isFollowing = false,
    this.mutualFriends = 0,
  });
}

class DiscoverItem {
  final String title;
  final String subtitle;
  final String category;
  final Color accentColor;
  final IconData icon;
  final String stat;

  const DiscoverItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.accentColor,
    required this.icon,
    required this.stat,
  });
}

enum MessageStatus { sending, sent, delivered, read }

// ─── Sample Data ──────────────────────────────────────────────────────────────

final _conversations = [
  const Conversation(
    id: '1',
    name: 'Sofia Reyes',
    avatarInitials: 'SR',
    avatarColor: Color(0xFF7C6AF7),
    lastMessage: 'Can you send the files before EOD? 🙏',
    time: '2m',
    unread: 3,
    online: true,
  ),
  const Conversation(
    id: '2',
    name: 'Design Team',
    avatarInitials: 'DT',
    avatarColor: Color(0xFFFF6B6B),
    lastMessage: 'Marcus: New mockups are ready for review',
    time: '18m',
    unread: 7,
    isGroup: true,
  ),
  const Conversation(
    id: '3',
    name: 'James Park',
    avatarInitials: 'JP',
    avatarColor: Color(0xFF3DD68C),
    lastMessage: 'Perfect, see you at the standup 👍',
    time: '1h',
    online: true,
  ),
  const Conversation(
    id: '4',
    name: 'Luna Chen',
    avatarInitials: 'LC',
    avatarColor: Color(0xFFFFB347),
    lastMessage: 'That presentation went really well!',
    time: '3h',
  ),
  const Conversation(
    id: '5',
    name: 'Product Squad',
    avatarInitials: 'PS',
    avatarColor: Color(0xFF4F8EF7),
    lastMessage: 'Aria: Sprint review is at 4pm today',
    time: 'Tue',
    isGroup: true,
  ),
  const Conversation(
    id: '6',
    name: 'Niko Andersen',
    avatarInitials: 'NA',
    avatarColor: Color(0xFFFF8CC8),
    lastMessage: 'Hey, are you free this weekend?',
    time: 'Mon',
  ),
  const Conversation(
    id: '7',
    name: 'Arjun Mehta',
    avatarInitials: 'AM',
    avatarColor: Color(0xFF00C9A7),
    lastMessage: 'The API integration is almost done',
    time: 'Sun',
  ),
];

final _messages = [
  const ChatMessage(
    text: 'Hey! Just wanted to check in about the project timeline.',
    isMe: false,
    time: '10:02 AM',
  ),
  const ChatMessage(
    text: 'We\'re on track! Finishing the last module today.',
    isMe: true,
    time: '10:05 AM',
  ),
  const ChatMessage(
    text: 'Amazing. The client is asking about the design assets too.',
    isMe: false,
    time: '10:06 AM',
  ),
  const ChatMessage(
    text: 'Can you send the files before EOD? 🙏',
    isMe: false,
    time: '10:06 AM',
  ),
  const ChatMessage(
    text: 'Of course! I\'ll package everything and send it over by 5pm.',
    isMe: true,
    time: '10:09 AM',
  ),
  const ChatMessage(
    text: 'Should I include the raw assets or just the exports?',
    isMe: true,
    time: '10:09 AM',
  ),
  const ChatMessage(
    text: 'Both would be great actually. The client might want to make small tweaks.',
    isMe: false,
    time: '10:12 AM',
  ),
  const ChatMessage(
    text: 'Got it! Will do 👌',
    isMe: true,
    time: '10:13 AM',
  ),
];

final _people = [
  const Person(
    name: 'Aria Fontaine',
    username: '@ariaf',
    avatarInitials: 'AF',
    avatarColor: Color(0xFFFF6B9D),
    online: true,
    mutualFriends: 5,
  ),
  const Person(
    name: 'Kai Nakamura',
    username: '@kainaka',
    avatarInitials: 'KN',
    avatarColor: Color(0xFF6B9DFF),
    online: true,
    isFollowing: true,
    mutualFriends: 12,
  ),
  const Person(
    name: 'Priya Sharma',
    username: '@priyash',
    avatarInitials: 'PS',
    avatarColor: Color(0xFFFFD166),
    mutualFriends: 3,
  ),
  const Person(
    name: 'Leo Vasquez',
    username: '@leov',
    avatarInitials: 'LV',
    avatarColor: Color(0xFF06D6A0),
    online: true,
    isFollowing: true,
    mutualFriends: 8,
  ),
  const Person(
    name: 'Mira Okafor',
    username: '@miraokafor',
    avatarInitials: 'MO',
    avatarColor: Color(0xFFEF476F),
    mutualFriends: 2,
  ),
  const Person(
    name: 'Theo Brennan',
    username: '@theob',
    avatarInitials: 'TB',
    avatarColor: Color(0xFF9B5DE5),
    online: true,
    mutualFriends: 6,
  ),
];

final _discoverItems = [
  const DiscoverItem(
    title: 'Flutter Devs PH',
    subtitle: 'Share tips, jobs, and Flutter news for Philippine developers.',
    category: 'Technology',
    accentColor: Color(0xFF54C5F8),
    icon: Icons.code_rounded,
    stat: '4.2k members',
  ),
  const DiscoverItem(
    title: 'Design Systems',
    subtitle: 'Discuss tokens, components, and scalable UI architecture.',
    category: 'Design',
    accentColor: Color(0xFFFF6B9D),
    icon: Icons.palette_rounded,
    stat: '8.7k members',
  ),
  const DiscoverItem(
    title: 'Startup Founders',
    subtitle: 'Connect with early-stage founders and share your journey.',
    category: 'Business',
    accentColor: Color(0xFFFFD166),
    icon: Icons.rocket_launch_rounded,
    stat: '2.1k members',
  ),
  const DiscoverItem(
    title: 'AI & ML Builders',
    subtitle: 'Researchers, engineers, and enthusiasts building with AI.',
    category: 'Technology',
    accentColor: Color(0xFF06D6A0),
    icon: Icons.psychology_rounded,
    stat: '15k members',
  ),
  const DiscoverItem(
    title: 'Remote Work Life',
    subtitle: 'Tips, tools, and community for distributed teams.',
    category: 'Lifestyle',
    accentColor: Color(0xFF9B5DE5),
    icon: Icons.laptop_mac_rounded,
    stat: '6.3k members',
  ),
  const DiscoverItem(
    title: 'Photography Club',
    subtitle: 'Share your shots and get feedback from fellow photographers.',
    category: 'Creative',
    accentColor: Color(0xFFEF476F),
    icon: Icons.camera_alt_rounded,
    stat: '3.8k members',
  ),
];

// ─── Conversations Screen ─────────────────────────────────────────────────────

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _searching = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStories(),
            const _SectionDivider(),
            Expanded(child: _buildConversationList()),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale:
            CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
        child: FloatingActionButton(
          backgroundColor: _accent,
          onPressed: () {},
          child: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messenger',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '10 unread messages',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderAction(icon: Icons.notifications_outlined, badge: true),
              const SizedBox(width: 8),
              const _Avatar(
                initials: 'ME',
                color: _accent,
                size: 36,
                showBorder: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchBar(
            controller: _searchController,
            onFocus: (v) => setState(() => _searching = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStories() {
    final people = [
      ('Sofia', const Color(0xFF7C6AF7), true),
      ('James', const Color(0xFF3DD68C), true),
      ('Marcus', const Color(0xFFFF6B6B), false),
      ('Luna', const Color(0xFFFFB347), false),
      ('Niko', const Color(0xFFFF8CC8), false),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: people.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, i) {
          final p = people[i];
          return _StoryBubble(name: p.$1, color: p.$2, online: p.$3);
        },
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _conversations.length,
      itemBuilder: (ctx, i) {
        final c = _conversations[i];
        return _ConversationTile(
          conversation: c,
          onTap: () => _openChat(c),
        );
      },
    );
  }

  void _openChat(Conversation c) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => ChatScreen(conversation: c),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// ─── People Screen ────────────────────────────────────────────────────────────

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _followingState = <int, bool>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    for (var i = 0; i < _people.length; i++) {
      _followingState[i] = _people[i].isFollowing;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPeopleList(suggested: true),
                  _buildPeopleList(onlineOnly: true),
                  _buildPeopleList(followingOnly: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'People',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '3 friends online now',
                      style: TextStyle(
                        fontSize: 13,
                        color: _green,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderAction(icon: Icons.person_add_outlined),
            ],
          ),
          const SizedBox(height: 14),
          _SearchBar(
            controller: _searchController,
            hint: 'Search people...',
            onFocus: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: _accent,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: _accent,
        unselectedLabelColor: _textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Suggested'),
          Tab(text: 'Online'),
          Tab(text: 'Following'),
        ],
      ),
    );
  }

  Widget _buildPeopleList({
    bool suggested = false,
    bool onlineOnly = false,
    bool followingOnly = false,
  }) {
    var filtered = <(int, Person)>[
      for (var i = 0; i < _people.length; i++) (i, _people[i])
    ];
    if (onlineOnly) {
      filtered = filtered.where((e) => e.$2.online).toList();
    } else if (followingOnly) {
      filtered = filtered.where((e) => _followingState[e.$1] == true).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              followingOnly
                  ? Icons.people_outline_rounded
                  : Icons.wifi_off_rounded,
              color: _textSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              followingOnly ? 'Not following anyone yet' : 'No one online',
              style: const TextStyle(color: _textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final (index, person) = filtered[i];
        return _PersonTile(
          person: person,
          isFollowing: _followingState[index] ?? false,
          onFollowToggle: () {
            setState(() {
              _followingState[index] = !(_followingState[index] ?? false);
            });
          },
        );
      },
    );
  }
}

class _PersonTile extends StatelessWidget {
  final Person person;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const _PersonTile({
    required this.person,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        splashColor: _accent.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              _Avatar(
                initials: person.avatarInitials,
                color: person.avatarColor,
                size: 50,
                online: person.online,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      person.username,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                    if (person.mutualFriends > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded,
                              size: 12, color: _textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${person.mutualFriends} mutual friends',
                            style: const TextStyle(
                                fontSize: 11, color: _textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onFollowToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFollowing ? _surfaceAlt : _accent,
                    borderRadius: BorderRadius.circular(20),
                    border: isFollowing
                        ? Border.all(color: _divider, width: 1)
                        : null,
                    boxShadow: isFollowing
                        ? null
                        : [
                            BoxShadow(
                              color: _accent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isFollowing ? _textSecondary : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Discover Screen ──────────────────────────────────────────────────────────

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final _joinedState = <int, bool>{};

  final _categories = ['All', 'Technology', 'Design', 'Business', 'Lifestyle', 'Creative'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<(int, DiscoverItem)> get _filtered {
    final indexed = <(int, DiscoverItem)>[
      for (var i = 0; i < _discoverItems.length; i++) (i, _discoverItems[i])
    ];
    if (_selectedCategory == 'All') return indexed;
    return indexed.where((e) => e.$2.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFeaturedCard()),
            SliverToBoxAdapter(child: _buildCategoryChips()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  'COMMUNITIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final filtered = _filtered;
                  if (i >= filtered.length) return null;
                  final (index, item) = filtered[i];
                  return _DiscoverCard(
                    item: item,
                    joined: _joinedState[index] ?? false,
                    onJoinToggle: () {
                      setState(
                          () => _joinedState[index] = !(_joinedState[index] ?? false));
                    },
                  );
                },
                childCount: _filtered.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Find communities & people',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderAction(icon: Icons.tune_rounded),
            ],
          ),
          const SizedBox(height: 14),
          _SearchBar(
            controller: _searchController,
            hint: 'Search communities...',
            onFocus: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A3F6F), Color(0xFF1A2A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _accent.withOpacity(0.3), width: 1),
                  ),
                  child: const Text(
                    '🔥 Trending this week',
                    style: TextStyle(
                      fontSize: 11,
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join AI & ML Builders',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          '15,000 members · 240 online',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Join',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _accent : _surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? null
                    : Border.all(color: _divider, width: 1),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : _textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  final DiscoverItem item;
  final bool joined;
  final VoidCallback onJoinToggle;

  const _DiscoverCard({
    required this.item,
    required this.joined,
    required this.onJoinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        splashColor: item.accentColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: _textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.groups_rounded,
                            size: 12, color: _textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.stat,
                          style: const TextStyle(
                              fontSize: 11, color: _textSecondary),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onJoinToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: joined ? _surfaceAlt : item.accentColor,
                              borderRadius: BorderRadius.circular(16),
                              border: joined
                                  ? Border.all(color: _divider, width: 1)
                                  : null,
                              boxShadow: joined
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: item.accentColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                            ),
                            child: Text(
                              joined ? 'Joined' : 'Join',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: joined ? _textSecondary : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Chat Screen ──────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late List<ChatMessage> _msgs;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _msgs = List.from(_messages);
    _textController.addListener(() {
      setState(() => _hasText = _textController.text.trim().isNotEmpty);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(ChatMessage(
        text: text,
        isMe: true,
        time: 'Now',
        status: MessageStatus.sending,
      ));
      _textController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildAppBar(c),
          Expanded(child: _buildMessages()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar(Conversation c) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: const BoxDecoration(
          color: _bg,
          border: Border(bottom: BorderSide(color: _divider, width: 0.5)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: _textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            _Avatar(
              initials: c.avatarInitials,
              color: c.avatarColor,
              size: 40,
              online: c.online,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    c.online ? 'Active now' : 'Last seen recently',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.online ? _green : _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.videocam_outlined,
                  color: _textPrimary, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.phone_outlined,
                  color: _textPrimary, size: 20),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _msgs.length,
        itemBuilder: (ctx, i) {
          final msg = _msgs[i];
          final prevIsMe = i > 0 ? _msgs[i - 1].isMe : null;
          final nextIsMe =
              i < _msgs.length - 1 ? _msgs[i + 1].isMe : null;
          final isFirst = prevIsMe != msg.isMe;
          final isLast = nextIsMe != msg.isMe;
          return _MessageBubble(
            message: msg,
            isFirst: isFirst,
            isLast: isLast,
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: _bg,
          border: Border(top: BorderSide(color: _divider, width: 0.5)),
        ),
        child: Row(
          children: [
            _InputAction(icon: Icons.add_circle_outline_rounded),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: _textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    if (!_hasText) ...[
                      _InputAction(icon: Icons.image_outlined),
                      _InputAction(icon: Icons.mic_none_rounded),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: _hasText
                  ? GestureDetector(
                      key: const ValueKey('send'),
                      onTap: _sendMessage,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  : GestureDetector(
                      key: const ValueKey('like'),
                      onTap: () {},
                      child: const Icon(
                        Icons.thumb_up_outlined,
                        color: _accent,
                        size: 28,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  final bool online;
  final bool showBorder;

  const _Avatar({
    required this.initials,
    required this.color,
    required this.size,
    this.online = false,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(color: _accent.withOpacity(0.6), width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: color,
                fontSize: size * 0.32,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
                border: Border.all(color: _bg, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final String name;
  final Color color;
  final bool online;

  const _StoryBubble({
    required this.name,
    required this.color,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _surfaceAlt,
            ),
            child: Center(
              child: Text(
                name[0],
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            color: online ? _textPrimary : _textSecondary,
            fontWeight: online ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text(
            'RECENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 0.5, color: _divider)),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final hasUnread = c.unread > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: _accent.withOpacity(0.05),
        highlightColor: _accent.withOpacity(0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              _Avatar(
                initials: c.avatarInitials,
                color: c.avatarColor,
                size: 52,
                online: c.online,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          c.time,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                hasUnread ? _accent : _textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: hasUnread
                                  ? _textPrimary.withOpacity(0.85)
                                  : _textSecondary,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            constraints:
                                const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6),
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${c.unread}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFirst;
  final bool isLast;

  const _MessageBubble({
    required this.message,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    final radius = BorderRadius.only(
      topLeft: Radius.circular(!isMe && !isFirst ? 4 : 18),
      topRight: Radius.circular(isMe && !isFirst ? 4 : 18),
      bottomLeft: Radius.circular(!isMe && !isLast ? 4 : 18),
      bottomRight: Radius.circular(isMe && !isLast ? 4 : 18),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 12 : 3,
        top: isFirst ? 4 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && isLast) ...[
            const _Avatar(
              initials: 'SR',
              color: Color(0xFF7C6AF7),
              size: 28,
            ),
            const SizedBox(width: 8),
          ] else if (!isMe)
            const SizedBox(width: 36),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _accent : _surface,
                borderRadius: radius,
                boxShadow: isMe
                    ? [
                        BoxShadow(
                          color: _accent.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : _textPrimary,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.time,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.6)
                              : _textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _StatusIcon(status: message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white54,
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check_rounded,
            size: 12, color: Colors.white54);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded,
            size: 12, color: Colors.white54);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 12, color: Colors.white);
    }
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<bool> onFocus;
  final String hint;

  const _SearchBar({
    required this.controller,
    required this.onFocus,
    this.hint = 'Search conversations...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: _textSecondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Focus(
              onFocusChange: onFocus,
              child: TextField(
                controller: controller,
                style:
                    const TextStyle(color: _textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                      color: _textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final bool badge;

  const _HeaderAction({required this.icon, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _textPrimary, size: 20),
        ),
        if (badge)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
                border: Border.all(color: _bg, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _InputAction extends StatelessWidget {
  final IconData icon;
  const _InputAction({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: _accent, size: 24);
  }
}