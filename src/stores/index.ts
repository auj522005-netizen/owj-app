import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// ═══════════════════ TYPES ═══════════════════

export interface ChatMessage {
  id: string;
  content: string;
  isUser: boolean;
  timestamp: number;
  provider?: string;
}

interface ChatStore {
  messages: ChatMessage[];
  isLoading: boolean;
  addMessage: (msg: ChatMessage) => void;
  clearMessages: () => void;
  setLoading: (loading: boolean) => void;
}

interface Task {
  id: string;
  title: string;
  description: string;
  priority: 'high' | 'medium' | 'low';
  category: string;
  isCompleted: boolean;
  createdAt: number;
}

interface TasksStore {
  tasks: Task[];
  addTask: (task: Omit<Task, 'id' | 'isCompleted' | 'createdAt' | 'category'>) => void;
  deleteTask: (id: string) => void;
  toggleTask: (id: string) => void;
}

interface Goal {
  id: string;
  title: string;
  description: string;
  progress: number;
  milestones: string[];
  createdAt: number;
}

interface GoalsStore {
  goals: Goal[];
  addGoal: (goal: Omit<Goal, 'id' | 'progress' | 'createdAt' | 'milestones'>) => void;
  deleteGoal: (id: string) => void;
  updateProgress: (id: string, delta: number) => void;
}

interface Habit {
  id: string;
  name: string;
  emoji: string;
  frequency: 'daily' | 'weekly';
  streak: number;
  completedDates: string[];
  createdAt: number;
}

interface HabitsStore {
  habits: Habit[];
  addHabit: (habit: Omit<Habit, 'id' | 'streak' | 'completedDates' | 'createdAt'>) => void;
  deleteHabit: (id: string) => void;
  toggleToday: (id: string) => void;
}

interface JournalEntry {
  id: string;
  title: string;
  content: string;
  mood: string;
  moodEmoji: string;
  createdAt: number;
}

interface JournalStore {
  entries: JournalEntry[];
  addEntry: (entry: Omit<JournalEntry, 'id' | 'createdAt'>) => void;
  deleteEntry: (id: string) => void;
}

interface Memory {
  id: string;
  content: string;
  category: string;
  tags: string[];
  createdAt: number;
}

interface MemoryStore {
  memories: Memory[];
  searchQuery: string;
  addMemory: (memory: Omit<Memory, 'id' | 'createdAt'>) => void;
  deleteMemory: (id: string) => void;
  setSearchQuery: (query: string) => void;
}

export interface Character {
  name: string;
  emoji: string;
  desc: string;
  system: string;
}

interface CharacterStore {
  activeCharacter: string;
  customCharacters: Character[];
  allCharacters: () => Character[];
  setActiveCharacter: (name: string) => void;
  addCustomCharacter: (char: Character) => void;
  removeCustomCharacter: (name: string) => void;
}

interface ApiKeyConfig {
  key: string;
  label: string;
  icon: string;
}

interface SettingsStore {
  selectedModel: string;
  apiKeys: Record<string, string>;
  isDarkMode: boolean;
  setSelectedModel: (model: string) => void;
  setApiKey: (key: string, value: string) => void;
  removeApiKey: (key: string) => void;
  setDarkMode: (dark: boolean) => void;
  resetApiKeys: () => void;
}

// ═══════════════════ CONSTANTS ═══════════════════

export const BUILT_IN_CHARACTERS: Character[] = [
  {
    name: 'Wesal',
    emoji: '💬',
    desc: 'Your close friend - understands your feelings and helps you in daily life',
    system: 'You are Wesal, a close friend who speaks in a warm and intimate style. You understand the user\'s feelings and help them in their daily life.',
  },
  {
    name: 'Hakeem',
    emoji: '🧠',
    desc: 'Your spiritual guide - offers wise advice inspired by wisdom and philosophy',
    system: 'You are Hakeem, a spiritual guide who speaks in a deep and wise style. You offer advice inspired by wisdom and philosophy.',
  },
  {
    name: 'Rafeeq',
    emoji: '🤝',
    desc: 'Your companion on the journey - encourages and supports you',
    system: 'You are Rafeeq, a supportive companion who speaks in a motivating and positive style. You encourage the user to achieve their goals.',
  },
  {
    name: 'Moalim',
    emoji: '📚',
    desc: 'Your personal teacher - explains any topic simply and clearly',
    system: 'You are Moalim, a personal teacher who speaks in a simple and clear educational style. You explain topics clearly and simplify information.',
  },
  {
    name: 'Mubasher',
    emoji: '🌟',
    desc: 'Your daily herald - tells you news, predictions, and events',
    system: 'You are Mubasher, a daily herald who speaks in a cheerful and positive style. You tell the user about news and positive predictions.',
  },
];

export const AI_PROVIDERS = ['Gemini', 'Groq', 'BigModel', 'OpenRouter', 'OpenAI', 'Cerebras'];

export const AI_MODELS: Record<string, string> = {
  'Gemini': 'gemini-2.0-flash',
  'Groq': 'llama-3.3-70b-versatile',
  'BigModel': 'glm-4-flash',
  'OpenRouter': 'google/gemini-2.0-flash-exp:free',
  'OpenAI': 'gpt-4o-mini',
  'Cerebras': 'llama-3.3-70b',
};

export const MODEL_CAPABILITIES: Record<string, string[]> = {
  'Gemini': ['Chat', 'Search', 'Analysis', 'Creative', 'Translation'],
  'Groq': ['Chat', 'Speed', 'Coding', 'Analysis', 'Math'],
  'BigModel': ['Chat', 'Analysis', 'Translation', 'Chinese'],
  'OpenRouter': ['Chat', 'Search', 'Analysis', 'Creative', 'Multi'],
  'OpenAI': ['Chat', 'Coding', 'Analysis', 'Creative', 'Math'],
  'Cerebras': ['Chat', 'Speed', 'Coding', 'Math'],
};

export const API_KEY_CONFIGS: ApiKeyConfig[] = [
  { key: 'api_key_gemini', label: 'Gemini (Google)', icon: 'auto_awesome' },
  { key: 'api_key_groq', label: 'Groq', icon: 'speed' },
  { key: 'api_key_bigmodel', label: 'BigModel (ZhipuAI)', icon: 'language' },
  { key: 'api_key_openrouter', label: 'OpenRouter', icon: 'router' },
  { key: 'api_key_openai', label: 'OpenAI', icon: 'smart_toy' },
  { key: 'api_key_cerebras', label: 'Cerebras', icon: 'memory' },
  { key: 'api_key_mem0', label: 'Memory (Mem0)', icon: 'psychology' },
  { key: 'api_key_tavily', label: 'Search (Tavily)', icon: 'search' },
  { key: 'api_key_tavily_mcp', label: 'Tavily MCP News', icon: 'newspaper' },
  { key: 'api_key_elevenlabs', label: 'Voice (ElevenLabs)', icon: 'record_voice_over' },
  { key: 'api_key_github', label: 'GitHub', icon: 'code' },
  { key: 'api_key_notion', label: 'Notion', icon: 'note' },
  { key: 'api_key_youtube', label: 'YouTube', icon: 'play_circle' },
  { key: 'api_key_gmail_client_id', label: 'Gmail - Client ID', icon: 'email' },
  { key: 'api_key_gmail_client_secret', label: 'Gmail - Client Secret', icon: 'lock' },
  { key: 'api_key_firebase_api', label: 'Firebase - API Key', icon: 'local_fire_department' },
  { key: 'api_key_firebase_project_id', label: 'Firebase - Project ID', icon: 'folder' },
  { key: 'api_key_firebase_app_id', label: 'Firebase - App ID', icon: 'phone_android' },
];

export const AI_KEY_CONFIGS = API_KEY_CONFIGS.filter(c =>
  ['api_key_gemini', 'api_key_groq', 'api_key_bigmodel', 'api_key_openrouter', 'api_key_openai', 'api_key_cerebras'].includes(c.key)
);

export const SEARCH_MEMORY_KEYS = API_KEY_CONFIGS.filter(c =>
  ['api_key_mem0', 'api_key_tavily', 'api_key_tavily_mcp', 'api_key_elevenlabs'].includes(c.key)
);

export const INTEGRATION_KEYS = API_KEY_CONFIGS.filter(c =>
  ['api_key_github', 'api_key_notion', 'api_key_youtube', 'api_key_gmail_client_id', 'api_key_gmail_client_secret'].includes(c.key)
);

export const FIREBASE_KEYS = API_KEY_CONFIGS.filter(c =>
  ['api_key_firebase_api', 'api_key_firebase_project_id', 'api_key_firebase_app_id'].includes(c.key)
);

export const MEMORY_CATEGORIES = ['Personal', 'Work', 'Learning', 'Health', 'Finance', 'Social'];

export const MOODS = [
  { emoji: '😊', label: 'Happy', value: 'happy' },
  { emoji: '😢', label: 'Sad', value: 'sad' },
  { emoji: '😐', label: 'Normal', value: 'normal' },
  { emoji: '🤩', label: 'Excited', value: 'excited' },
  { emoji: '😟', label: 'Anxious', value: 'anxious' },
  { emoji: '😌', label: 'Calm', value: 'calm' },
];

export const HABIT_EMOJIS = ['💪', '📖', '🏃', '🧘', '💊', '💧', '🎯', '✍️', '🎵', '🌅', '🧹', '🍳', '💤', '🧠', '🌱', '💪'];

// ═══════════════════ STORES ═══════════════════

export const useChatStore = create<ChatStore>()(
  persist(
    (set) => ({
      messages: [],
      isLoading: false,
      addMessage: (msg) => set((state) => ({ messages: [...state.messages, msg] })),
      clearMessages: () => set({ messages: [] }),
      setLoading: (loading) => set({ isLoading: loading }),
    }),
    { name: 'owj-chat' }
  )
);

export const useTasksStore = create<TasksStore>()(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) =>
        set((state) => ({
          tasks: [
            {
              ...task,
              id: crypto.randomUUID(),
              category: 'General',
              isCompleted: false,
              createdAt: Date.now(),
            },
            ...state.tasks,
          ],
        })),
      deleteTask: (id) => set((state) => ({ tasks: state.tasks.filter((t) => t.id !== id) })),
      toggleTask: (id) =>
        set((state) => ({
          tasks: state.tasks.map((t) => (t.id === id ? { ...t, isCompleted: !t.isCompleted } : t)),
        })),
    }),
    { name: 'owj-tasks' }
  )
);

export const useGoalsStore = create<GoalsStore>()(
  persist(
    (set) => ({
      goals: [],
      addGoal: (goal) =>
        set((state) => ({
          goals: [
            {
              ...goal,
              id: crypto.randomUUID(),
              progress: 0,
              milestones: [],
              createdAt: Date.now(),
            },
            ...state.goals,
          ],
        })),
      deleteGoal: (id) => set((state) => ({ goals: state.goals.filter((g) => g.id !== id) })),
      updateProgress: (id, delta) =>
        set((state) => ({
          goals: state.goals.map((g) =>
            g.id === id ? { ...g, progress: Math.min(100, Math.max(0, g.progress + delta)) } : g
          ),
        })),
    }),
    { name: 'owj-goals' }
  )
);

export const useHabitsStore = create<HabitsStore>()(
  persist(
    (set) => ({
      habits: [],
      addHabit: (habit) =>
        set((state) => ({
          habits: [
            {
              ...habit,
              id: crypto.randomUUID(),
              streak: 0,
              completedDates: [],
              createdAt: Date.now(),
            },
            ...state.habits,
          ],
        })),
      deleteHabit: (id) => set((state) => ({ habits: state.habits.filter((h) => h.id !== id) })),
      toggleToday: (id) =>
        set((state) => {
          const today = new Date().toISOString().split('T')[0];
          return {
            habits: state.habits.map((h) => {
              if (h.id !== id) return h;
              const isCompleted = h.completedDates.includes(today);
              const completedDates = isCompleted
                ? h.completedDates.filter((d) => d !== today)
                : [...h.completedDates, today];
              const streak = isCompleted
                ? Math.max(0, h.streak - 1)
                : h.streak + 1;
              return { ...h, completedDates, streak };
            }),
          };
        }),
    }),
    { name: 'owj-habits' }
  )
);

export const useJournalStore = create<JournalStore>()(
  persist(
    (set) => ({
      entries: [],
      addEntry: (entry) =>
        set((state) => ({
          entries: [
            {
              ...entry,
              id: crypto.randomUUID(),
              createdAt: Date.now(),
            },
            ...state.entries,
          ],
        })),
      deleteEntry: (id) => set((state) => ({ entries: state.entries.filter((e) => e.id !== id) })),
    }),
    { name: 'owj-journal' }
  )
);

export const useMemoryStore = create<MemoryStore>()(
  persist(
    (set) => ({
      memories: [],
      searchQuery: '',
      addMemory: (memory) =>
        set((state) => ({
          memories: [
            {
              ...memory,
              id: crypto.randomUUID(),
              createdAt: Date.now(),
            },
            ...state.memories,
          ],
        })),
      deleteMemory: (id) => set((state) => ({ memories: state.memories.filter((m) => m.id !== id) })),
      setSearchQuery: (query) => set({ searchQuery: query }),
    }),
    { name: 'owj-memory' }
  )
);

export const useCharacterStore = create<CharacterStore>()(
  persist(
    (set, get) => ({
      activeCharacter: 'Wesal',
      customCharacters: [],
      allCharacters: () => [...BUILT_IN_CHARACTERS, ...get().customCharacters],
      setActiveCharacter: (name) => set({ activeCharacter: name }),
      addCustomCharacter: (char) =>
        set((state) => ({
          customCharacters: [...state.customCharacters, char],
        })),
      removeCustomCharacter: (name) =>
        set((state) => ({
          customCharacters: state.customCharacters.filter((c) => c.name !== name),
          activeCharacter: state.activeCharacter === name ? 'Wesal' : state.activeCharacter,
        })),
    }),
    { name: 'owj-character' }
  )
);

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      selectedModel: 'Gemini',
      apiKeys: {},
      isDarkMode: true,
      setSelectedModel: (model) => set({ selectedModel: model }),
      setApiKey: (key, value) =>
        set((state) => ({
          apiKeys: { ...state.apiKeys, [key]: value },
        })),
      removeApiKey: (key) =>
        set((state) => {
          const newKeys = { ...state.apiKeys };
          delete newKeys[key];
          return { apiKeys: newKeys };
        }),
      setDarkMode: (dark) => set({ isDarkMode: dark }),
      resetApiKeys: () => set({ apiKeys: {} }),
    }),
    { name: 'owj-settings' }
  )
);
