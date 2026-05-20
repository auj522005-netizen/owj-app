'use client'

import React, { useState, useRef, useEffect, useCallback } from 'react'
import { useTheme } from 'next-themes'
import { motion, AnimatePresence } from 'framer-motion'
import {
  MessageCircle, CheckCircle2, Flag, Repeat, BookOpen, Brain, Bot, Settings,
  Send, Trash2, Plus, ChevronRight, Search, X, CircleDot,
  Flame, Save, Eye, EyeOff, Key, Cpu, Info, Copy, RotateCcw,
  Moon, Sun, Lock, Check, Radio, Star, StickyNote, Lightbulb,
  Briefcase, Activity, Phone
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Switch } from '@/components/ui/switch'
import { Progress } from '@/components/ui/progress'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription
} from '@/components/ui/dialog'
import {
  Sheet, SheetContent, SheetHeader, SheetTitle, SheetDescription
} from '@/components/ui/sheet'
import {
  useChatStore, useTasksStore, useGoalsStore, useHabitsStore,
  useJournalStore, useMemoryStore, useCharacterStore, useSettingsStore,
  BUILT_IN_CHARACTERS, AI_PROVIDERS, AI_MODELS, MODEL_CAPABILITIES,
  API_KEY_CONFIGS, AI_KEY_CONFIGS, SEARCH_MEMORY_KEYS, INTEGRATION_KEYS,
  FIREBASE_KEYS, MEMORY_CATEGORIES, MOODS, HABIT_EMOJIS,
  type ChatMessage
} from '@/stores'

// ═══════════════════ ICON MAP ═══════════════════
const ICON_MAP: Record<string, React.ReactNode> = {
  auto_awesome: <Star className="w-4 h-4" />,
  speed: <Activity className="w-4 h-4" />,
  language: <Globe className="w-4 h-4" />,
  router: <ChevronRight className="w-4 h-4" />,
  smart_toy: <Bot className="w-4 h-4" />,
  memory: <Brain className="w-4 h-4" />,
  psychology: <Brain className="w-4 h-4" />,
  search: <Search className="w-4 h-4" />,
  newspaper: <BookOpen className="w-4 h-4" />,
  record_voice_over: <Phone className="w-4 h-4" />,
  code: <Lightbulb className="w-4 h-4" />,
  note: <StickyNote className="w-4 h-4" />,
  play_circle: <CircleDot className="w-4 h-4" />,
  email: <MessageCircle className="w-4 h-4" />,
  lock: <Lock className="w-4 h-4" />,
  local_fire_department: <Flame className="w-4 h-4" />,
  folder: <Briefcase className="w-4 h-4" />,
  phone_android: <Phone className="w-4 h-4" />,
}

function Globe({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10"/><path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"/><path d="M2 12h20"/>
    </svg>
  )
}

const PROVIDER_ICON_MAP: Record<string, React.ReactNode> = {
  Gemini: ICON_MAP.auto_awesome,
  Groq: ICON_MAP.speed,
  BigModel: ICON_MAP.language,
  OpenRouter: ICON_MAP.router,
  OpenAI: ICON_MAP.smart_toy,
  Cerebras: ICON_MAP.memory,
}

// ═══════════════════ MAIN APP ═══════════════════
export default function Home() {
  const [activeTab, setActiveTab] = useState(0)
  const { theme, setTheme } = useTheme()

  const navItems = [
    { label: 'Chat', icon: MessageCircle },
    { label: 'Tasks', icon: CheckCircle2 },
    { label: 'Goals', icon: Flag },
    { label: 'Habits', icon: Repeat },
    { label: 'Journal', icon: BookOpen },
    { label: 'Memory', icon: Brain },
    { label: 'Characters', icon: Bot },
    { label: 'Settings', icon: Settings },
  ]

  const screenTitles = ['Chat', 'Tasks', 'Goals', 'Habits', 'Journal', 'Memory', 'Characters', 'Settings']

  return (
    <div className="flex flex-col h-screen max-w-lg mx-auto bg-background">
      {/* App Bar */}
      <header className="flex items-center justify-between px-4 h-14 border-b border-border bg-background shrink-0">
        <h1 className="text-lg font-bold text-gold">OWJ</h1>
        <h2 className="text-sm font-semibold text-foreground">{screenTitles[activeTab]}</h2>
        <div className="w-12" />
      </header>

      {/* Screen Content */}
      <main className="flex-1 overflow-hidden">
        <AnimatePresence mode="wait">
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, x: 10 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -10 }}
            transition={{ duration: 0.15 }}
            className="h-full"
          >
            {activeTab === 0 && <ChatScreen />}
            {activeTab === 1 && <TasksScreen />}
            {activeTab === 2 && <GoalsScreen />}
            {activeTab === 3 && <HabitsScreen />}
            {activeTab === 4 && <JournalScreen />}
            {activeTab === 5 && <MemoryScreen />}
            {activeTab === 6 && <CharactersScreen />}
            {activeTab === 7 && <SettingsScreen />}
          </motion.div>
        </AnimatePresence>
      </main>

      {/* Bottom Navigation */}
      <nav className="shrink-0 border-t border-border bg-card shadow-lg">
        <div className="flex justify-around items-center py-1.5 px-1">
          {navItems.map((item, index) => {
            const isActive = activeTab === index
            const Icon = item.icon
            return (
              <button
                key={item.label}
                onClick={() => setActiveTab(index)}
                className={`flex flex-col items-center justify-center py-1 px-1.5 rounded-lg transition-all duration-200 min-w-0 ${
                  isActive ? 'text-gold' : 'text-muted-foreground hover:text-foreground'
                }`}
              >
                <Icon className={isActive ? 'w-5 h-5' : 'w-[18px] h-[18px]'} strokeWidth={isActive ? 2.5 : 2} />
                <span className={`mt-0.5 leading-tight ${isActive ? 'text-[10px] font-bold' : 'text-[9px]'}`}>
                  {item.label}
                </span>
              </button>
            )
          })}
        </div>
      </nav>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// CHAT SCREEN
// ═══════════════════════════════════════════════════════
function ChatScreen() {
  const { messages, isLoading, addMessage, clearMessages, setLoading } = useChatStore()
  const { activeCharacter, allCharacters } = useCharacterStore()
  const { selectedModel } = useSettingsStore()
  const [input, setInput] = useState('')
  const [showClearDialog, setShowClearDialog] = useState(false)
  const [showModelPicker, setShowModelPicker] = useState(false)
  const scrollRef = useRef<HTMLDivElement>(null)

  const currentChar = allCharacters().find(c => c.name === activeCharacter) || BUILT_IN_CHARACTERS[0]

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [messages, isLoading])

  const sendMessage = useCallback(async () => {
    const text = input.trim()
    if (!text || isLoading) return
    setInput('')
    addMessage({ id: crypto.randomUUID(), content: text, isUser: true, timestamp: Date.now() })
    setLoading(true)

    // Simulate AI response
    setTimeout(() => {
      const responses = [
        `Hey! I'm ${currentChar.name}. How can I help you today? 😊`,
        "That's a great question! Let me think about that...",
        "I understand what you mean. Here's what I think...",
        "Sure! I'd be happy to help with that.",
        "That's interesting! Let me share my thoughts on that.",
      ]
      addMessage({
        id: crypto.randomUUID(),
        content: responses[Math.floor(Math.random() * responses.length)],
        isUser: false,
        timestamp: Date.now(),
        provider: selectedModel,
      })
      setLoading(false)
    }, 1500 + Math.random() * 1000)
  }, [input, isLoading, currentChar.name, selectedModel, addMessage, setLoading])

  const suggestions = [
    'Add a task for me to finish the project',
    'Make a plan for my day',
    'Help me organize my goals',
    'Tell me something motivating',
    'Add a habit: drink water daily',
  ]

  return (
    <div className="flex flex-col h-full">
      {/* Chat Messages */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto custom-scrollbar">
        {messages.length === 0 ? (
          <div className="flex flex-col items-center justify-center min-h-full px-6 py-12">
            <motion.div
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ type: 'spring', stiffness: 200, damping: 15 }}
              className="relative"
            >
              <div className="w-24 h-24 rounded-full bg-gold/10 border-2 border-gold/40 flex items-center justify-center shadow-lg shadow-gold/20 mb-4">
                <span className="text-5xl">{currentChar.emoji}</span>
              </div>
            </motion.div>
            <motion.h2
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.15 }}
              className="text-2xl font-bold text-gold mb-2"
            >
              {currentChar.name}
            </motion.h2>
            <motion.p
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.25 }}
              className="text-muted-foreground text-center text-sm leading-relaxed mb-8 max-w-xs"
            >
              {currentChar.desc}
            </motion.p>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.35 }}
              className="flex flex-col gap-2 w-full max-w-xs"
            >
              {suggestions.map((s) => (
                <button
                  key={s}
                  onClick={() => { setInput(s); }}
                  className="w-full text-left px-4 py-2.5 rounded-xl border border-gold/30 bg-card text-gold text-xs hover:bg-gold/10 transition-colors"
                >
                  {s}
                </button>
              ))}
            </motion.div>
          </div>
        ) : (
          <div className="p-4 space-y-3 pb-4">
            {messages.map((msg) => (
              <MessageBubble key={msg.id} msg={msg} charEmoji={currentChar.emoji} />
            ))}
            {isLoading && <TypingIndicator emoji={currentChar.emoji} />}
          </div>
        )}
      </div>

      {/* Input Area */}
      <div className="shrink-0 border-t border-border bg-card px-3 py-2">
        <div className="flex items-end gap-2">
          <div className="flex-1 relative">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage() } }}
              placeholder="Type your message..."
              className="w-full rounded-full bg-muted px-4 py-2.5 pr-4 text-sm text-foreground placeholder:text-muted-foreground outline-none focus:ring-2 focus:ring-gold/50"
            />
          </div>
          <button
            onClick={sendMessage}
            disabled={isLoading || !input.trim()}
            className="shrink-0 w-10 h-10 rounded-full bg-gold flex items-center justify-center shadow-md shadow-gold/30 hover:bg-gold/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <div className="w-5 h-5 border-2 border-gold-foreground/30 border-t-gold-foreground rounded-full animate-spin" />
            ) : (
              <Send className="w-4 h-4 text-gold-foreground" />
            )}
          </button>
        </div>
      </div>

      {/* Clear Dialog */}
      <Dialog open={showClearDialog} onOpenChange={setShowClearDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Clear Chat</DialogTitle>
            <DialogDescription>Are you sure you want to clear all messages?</DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowClearDialog(false)}>Cancel</Button>
            <Button variant="destructive" onClick={() => { clearMessages(); setShowClearDialog(false) }}>Clear</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Model Picker */}
      <Sheet open={showModelPicker} onOpenChange={setShowModelPicker}>
        <SheetContent side="bottom" className="rounded-t-2xl max-h-[70vh]">
          <SheetHeader>
            <SheetTitle className="text-gold">Select AI Model</SheetTitle>
            <SheetDescription>Choose the AI model to chat with</SheetDescription>
          </SheetHeader>
          <div className="space-y-2 mt-4 overflow-y-auto max-h-[50vh] custom-scrollbar">
            {AI_PROVIDERS.map((provider) => {
              const isSelected = selectedModel === provider
              const model = AI_MODELS[provider] || ''
              const caps = (MODEL_CAPABILITIES[provider] || []).slice(0, 3).join(' · ')
              const IconComp = PROVIDER_ICON_MAP[provider]
              return (
                <button
                  key={provider}
                  onClick={() => { useSettingsStore.getState().setSelectedModel(provider); setShowModelPicker(false) }}
                  className={`w-full flex items-center gap-3 p-3 rounded-xl border transition-all ${
                    isSelected
                      ? 'border-gold bg-gold/10'
                      : 'border-border bg-card hover:border-gold/30'
                  }`}
                >
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                    isSelected ? 'bg-gold/20 text-gold' : 'bg-muted text-muted-foreground'
                  }`}>
                    {IconComp}
                  </div>
                  <div className="flex-1 text-left min-w-0">
                    <div className="flex items-center gap-2">
                      <span className={`text-sm font-semibold ${isSelected ? 'text-gold' : 'text-foreground'}`}>
                        {provider}
                      </span>
                      <span className="text-[10px] text-muted-foreground bg-muted px-2 py-0.5 rounded-full truncate max-w-[140px]">
                        {model}
                      </span>
                    </div>
                    <p className="text-[11px] text-muted-foreground mt-0.5">{caps}</p>
                  </div>
                  {isSelected ? (
                    <Check className="w-5 h-5 text-gold shrink-0" />
                  ) : (
                    <Radio className="w-5 h-5 text-muted-foreground shrink-0" />
                  )}
                </button>
              )
            })}
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}

function MessageBubble({ msg, charEmoji }: { msg: ChatMessage; charEmoji: string }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      className={`flex items-end gap-2 ${msg.isUser ? 'flex-row-reverse' : 'flex-row'}`}
    >
      {!msg.isUser && (
        <div className="w-8 h-8 rounded-full bg-gold/10 border border-gold/30 flex items-center justify-center shrink-0 mb-1">
          <span className="text-sm">{charEmoji}</span>
        </div>
      )}
      <div
        className={`max-w-[75%] px-4 py-2.5 rounded-2xl text-sm leading-relaxed ${
          msg.isUser
            ? 'bg-gold/15 border border-gold/30 text-gold rounded-bl-sm'
            : 'bg-card border border-border text-foreground rounded-br-sm'
        }`}
      >
        <p>{msg.content}</p>
        {msg.provider && (
          <p className="text-[9px] text-muted-foreground mt-1">{msg.provider}</p>
        )}
      </div>
    </motion.div>
  )
}

function TypingIndicator({ emoji }: { emoji: string }) {
  return (
    <div className="flex items-end gap-2">
      <div className="w-8 h-8 rounded-full bg-gold/10 border border-gold/30 flex items-center justify-center shrink-0">
        <span className="text-sm">{emoji}</span>
      </div>
      <div className="bg-card border border-border rounded-2xl rounded-br-sm px-4 py-3 flex items-center gap-1.5">
        <div className="w-2 h-2 rounded-full bg-gold typing-dot-1" />
        <div className="w-2 h-2 rounded-full bg-gold typing-dot-2" />
        <div className="w-2 h-2 rounded-full bg-gold typing-dot-3" />
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// TASKS SCREEN
// ═══════════════════════════════════════════════════════
function TasksScreen() {
  const { tasks, addTask, deleteTask, toggleTask } = useTasksStore()
  const [taskTab, setTaskTab] = useState('all')
  const [showAddSheet, setShowAddSheet] = useState(false)
  const [title, setTitle] = useState('')
  const [desc, setDesc] = useState('')
  const [priority, setPriority] = useState<'high' | 'medium' | 'low'>('medium')

  const filteredTasks = taskTab === 'all' ? tasks : taskTab === 'progress' ? tasks.filter(t => !t.isCompleted) : tasks.filter(t => t.isCompleted)

  const priorityColors = { high: 'bg-red-500/20 text-red-500', medium: 'bg-yellow-500/20 text-yellow-500', low: 'bg-green-500/20 text-green-500' }
  const priorityLabels = { high: 'High', medium: 'Medium', low: 'Low' }

  const handleAdd = () => {
    if (!title.trim()) return
    addTask({ title: title.trim(), description: desc.trim(), priority })
    setTitle(''); setDesc(''); setPriority('medium')
    setShowAddSheet(false)
  }

  return (
    <div className="flex flex-col h-full">
      <Tabs value={taskTab} onValueChange={setTaskTab} className="flex flex-col h-full">
        <TabsList className="w-full rounded-none bg-card border-b border-border h-11">
          <TabsTrigger value="all" className="flex-1 text-xs data-[state=active]:text-gold data-[state=active]:bg-transparent">All Tasks</TabsTrigger>
          <TabsTrigger value="progress" className="flex-1 text-xs data-[state=active]:text-gold data-[state=active]:bg-transparent">In Progress</TabsTrigger>
          <TabsTrigger value="completed" className="flex-1 text-xs data-[state=active]:text-gold data-[state=active]:bg-transparent">Completed</TabsTrigger>
        </TabsList>

        <div className="flex-1 overflow-y-auto">
          {filteredTasks.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
              <CheckCircle2 className="w-16 h-16 mb-4 opacity-40" />
              <p className="text-sm">No tasks yet</p>
            </div>
          ) : (
            <div className="p-4 space-y-2.5">
              {filteredTasks.map((task) => (
                <motion.div
                  key={task.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-card border border-border rounded-xl p-3.5 flex items-start gap-3"
                >
                  <button
                    onClick={() => toggleTask(task.id)}
                    className="mt-0.5 w-6 h-6 rounded-full border-2 flex items-center justify-center shrink-0 transition-colors"
                    style={{
                      borderColor: task.isCompleted ? '#22c55e' : 'hsl(var(--muted-foreground))',
                      backgroundColor: task.isCompleted ? '#22c55e' : 'transparent',
                    }}
                  >
                    {task.isCompleted && <Check className="w-3.5 h-3.5 text-white" />}
                  </button>
                  <div className="flex-1 min-w-0">
                    <p className={`text-sm font-semibold ${task.isCompleted ? 'line-through text-muted-foreground' : 'text-foreground'}`}>
                      {task.title}
                    </p>
                    {task.description && (
                      <p className="text-xs text-muted-foreground mt-0.5">{task.description}</p>
                    )}
                    <div className="flex items-center gap-2 mt-2">
                      <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium ${priorityColors[task.priority]}`}>
                        {priorityLabels[task.priority]}
                      </span>
                      <span className="text-[10px] px-2 py-0.5 rounded-full bg-gold/20 text-gold font-medium">
                        General
                      </span>
                    </div>
                  </div>
                  <button onClick={() => deleteTask(task.id)} className="text-red-500 hover:text-red-400 mt-0.5">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      </Tabs>

      {/* FAB */}
      <button
        onClick={() => setShowAddSheet(true)}
        className="absolute bottom-20 right-4 w-12 h-12 rounded-full bg-gold shadow-lg shadow-gold/30 flex items-center justify-center hover:bg-gold/90 transition-colors"
      >
        <Plus className="w-6 h-6 text-gold-foreground" />
      </button>

      {/* Add Task Sheet */}
      <Sheet open={showAddSheet} onOpenChange={setShowAddSheet}>
        <SheetContent side="bottom" className="rounded-t-2xl">
          <SheetHeader>
            <SheetTitle className="text-gold">Add New Task</SheetTitle>
          </SheetHeader>
          <div className="space-y-3 mt-4">
            <Input placeholder="Task title" value={title} onChange={(e) => setTitle(e.target.value)} className="bg-muted border-0" />
            <Textarea placeholder="Description (optional)" value={desc} onChange={(e) => setDesc(e.target.value)} className="bg-muted border-0 min-h-[60px]" />
            <div>
              <p className="text-xs text-muted-foreground mb-2">Priority:</p>
              <div className="flex gap-2">
                {(['high', 'medium', 'low'] as const).map((p) => (
                  <button
                    key={p}
                    onClick={() => setPriority(p)}
                    className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                      priority === p ? 'bg-gold text-gold-foreground' : 'bg-card text-muted-foreground border border-border'
                    }`}
                  >
                    {priorityLabels[p]}
                  </button>
                ))}
              </div>
            </div>
            <Button onClick={handleAdd} className="w-full bg-gold text-gold-foreground hover:bg-gold/90" disabled={!title.trim()}>
              Add Task
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// GOALS SCREEN
// ═══════════════════════════════════════════════════════
function GoalsScreen() {
  const { goals, addGoal, deleteGoal, updateProgress } = useGoalsStore()
  const [showAddSheet, setShowAddSheet] = useState(false)
  const [title, setTitle] = useState('')
  const [desc, setDesc] = useState('')
  const [milestone, setMilestone] = useState('')
  const [milestones, setMilestones] = useState<string[]>([])

  const handleAdd = () => {
    if (!title.trim()) return
    addGoal({ title: title.trim(), description: desc.trim() })
    setTitle(''); setDesc(''); setMilestones([])
    setShowAddSheet(false)
  }

  const addMilestone = () => {
    if (milestone.trim() && milestones.length < 10) {
      setMilestones([...milestones, milestone.trim()])
      setMilestone('')
    }
  }

  return (
    <div className="flex flex-col h-full relative">
      <div className="flex-1 overflow-y-auto">
        {goals.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
            <Flag className="w-16 h-16 mb-4 opacity-40" />
            <p className="text-sm">No goals yet</p>
          </div>
        ) : (
          <div className="p-4 space-y-3">
            {goals.map((goal) => (
              <motion.div
                key={goal.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-card border border-border rounded-xl p-4"
              >
                <div className="flex items-start justify-between mb-2">
                  <div className="flex-1 min-w-0">
                    <h3 className="text-sm font-bold text-foreground">{goal.title}</h3>
                    {goal.description && <p className="text-xs text-muted-foreground mt-0.5">{goal.description}</p>}
                  </div>
                  <button onClick={() => deleteGoal(goal.id)} className="text-red-500 ml-2 shrink-0">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-lg font-bold text-gold">{goal.progress}%</span>
                  <div className="flex-1">
                    <Progress value={goal.progress} className="h-2 [&>div]:bg-gold" />
                  </div>
                </div>
                {goal.progress < 100 && (
                  <button
                    onClick={() => updateProgress(goal.id, 10)}
                    className="text-[11px] px-3 py-1 rounded-full bg-gold/20 text-gold hover:bg-gold/30 transition-colors font-medium"
                  >
                    +10%
                  </button>
                )}
                {goal.milestones && goal.milestones.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 mt-2">
                    {goal.milestones.map((m, i) => (
                      <Badge key={i} variant="secondary" className="text-[10px]">{m}</Badge>
                    ))}
                  </div>
                )}
              </motion.div>
            ))}
          </div>
        )}
      </div>

      <button
        onClick={() => setShowAddSheet(true)}
        className="absolute bottom-4 right-4 w-12 h-12 rounded-full bg-gold shadow-lg shadow-gold/30 flex items-center justify-center"
      >
        <Plus className="w-6 h-6 text-gold-foreground" />
      </button>

      <Sheet open={showAddSheet} onOpenChange={setShowAddSheet}>
        <SheetContent side="bottom" className="rounded-t-2xl">
          <SheetHeader>
            <SheetTitle className="text-gold">Add New Goal</SheetTitle>
          </SheetHeader>
          <div className="space-y-3 mt-4">
            <Input placeholder="Goal title" value={title} onChange={(e) => setTitle(e.target.value)} className="bg-muted border-0" />
            <Textarea placeholder="Description" value={desc} onChange={(e) => setDesc(e.target.value)} className="bg-muted border-0 min-h-[60px]" />
            <div>
              <p className="text-xs text-muted-foreground mb-2">Milestones:</p>
              <div className="flex gap-2 mb-2">
                <Input
                  placeholder="Add milestone"
                  value={milestone}
                  onChange={(e) => setMilestone(e.target.value)}
                  onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addMilestone() } }}
                  className="bg-muted border-0 flex-1"
                />
                <Button size="sm" onClick={addMilestone} className="bg-gold text-gold-foreground shrink-0">
                  <Plus className="w-4 h-4" />
                </Button>
              </div>
              <div className="flex flex-wrap gap-1.5">
                {milestones.map((m, i) => (
                  <Badge key={i} variant="secondary" className="text-[10px] cursor-pointer" onClick={() => setMilestones(milestones.filter((_, idx) => idx !== i))}>
                    {m} ×
                  </Badge>
                ))}
              </div>
            </div>
            <Button onClick={handleAdd} className="w-full bg-gold text-gold-foreground hover:bg-gold/90" disabled={!title.trim()}>
              Add Goal
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// HABITS SCREEN
// ═══════════════════════════════════════════════════════
function HabitsScreen() {
  const { habits, addHabit, deleteHabit, toggleToday } = useHabitsStore()
  const [showAddSheet, setShowAddSheet] = useState(false)
  const [name, setName] = useState('')
  const [emoji, setEmoji] = useState('💪')
  const [frequency, setFrequency] = useState<'daily' | 'weekly'>('daily')

  const today = new Date().toISOString().split('T')[0]
  const completedToday = habits.filter(h => h.completedDates.includes(today)).length
  const todayPercent = habits.length > 0 ? Math.round((completedToday / habits.length) * 100) : 0

  const handleAdd = () => {
    if (!name.trim()) return
    addHabit({ name: name.trim(), emoji, frequency })
    setName(''); setEmoji('💪'); setFrequency('daily')
    setShowAddSheet(false)
  }

  return (
    <div className="flex flex-col h-full relative">
      <div className="flex-1 overflow-y-auto">
        {/* Today's progress */}
        {habits.length > 0 && (
          <div className="mx-4 mt-4 p-4 rounded-xl bg-gold/10 border border-gold/30">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-bold text-gold">Today&apos;s Progress</span>
              <span className="text-lg font-bold text-gold">{todayPercent}%</span>
            </div>
            <Progress value={todayPercent} className="h-2 [&>div]:bg-gold" />
            <p className="text-xs text-muted-foreground mt-1.5">{completedToday} of {habits.length} completed</p>
          </div>
        )}

        {habits.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-[60vh] text-muted-foreground">
            <Repeat className="w-16 h-16 mb-4 opacity-40" />
            <p className="text-sm">No habits yet</p>
          </div>
        ) : (
          <div className="p-4 space-y-2.5">
            {habits.map((habit) => {
              const isCompleted = habit.completedDates.includes(today)
              return (
                <motion.div
                  key={habit.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  className={`bg-card border rounded-xl p-3.5 flex items-center gap-3 transition-all ${isCompleted ? 'border-gold/30 bg-gold/5' : 'border-border'}`}
                >
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center text-lg shrink-0 ${isCompleted ? 'bg-gold/20' : 'bg-muted'}`}>
                    {habit.emoji}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className={`text-sm font-semibold ${isCompleted ? 'text-gold line-through' : 'text-foreground'}`}>
                      {habit.name}
                    </p>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className="text-xs text-muted-foreground capitalize">{habit.frequency}</span>
                      {habit.streak > 0 && (
                        <span className="text-xs text-orange-500">
                          🔥 {habit.streak} day streak
                        </span>
                      )}
                    </div>
                  </div>
                  <button
                    onClick={() => toggleToday(habit.id)}
                    className={`w-8 h-8 rounded-full border-2 flex items-center justify-center shrink-0 transition-colors ${
                      isCompleted ? 'bg-gold border-gold' : 'border-muted-foreground/40'
                    }`}
                  >
                    {isCompleted && <Check className="w-4 h-4 text-gold-foreground" />}
                  </button>
                  <button onClick={() => deleteHabit(habit.id)} className="text-red-500 shrink-0">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </motion.div>
              )
            })}
          </div>
        )}
      </div>

      <button
        onClick={() => setShowAddSheet(true)}
        className="absolute bottom-4 right-4 w-12 h-12 rounded-full bg-gold shadow-lg shadow-gold/30 flex items-center justify-center"
      >
        <Plus className="w-6 h-6 text-gold-foreground" />
      </button>

      <Sheet open={showAddSheet} onOpenChange={setShowAddSheet}>
        <SheetContent side="bottom" className="rounded-t-2xl">
          <SheetHeader>
            <SheetTitle className="text-gold">Add New Habit</SheetTitle>
          </SheetHeader>
          <div className="space-y-3 mt-4">
            <div className="flex justify-center">
              <div className="w-16 h-16 rounded-full bg-gold/10 border-2 border-gold flex items-center justify-center text-3xl">
                {emoji}
              </div>
            </div>
            <div className="flex flex-wrap gap-2 justify-center">
              {HABIT_EMOJIS.map((e) => (
                <button
                  key={e}
                  onClick={() => setEmoji(e)}
                  className={`w-10 h-10 rounded-xl flex items-center justify-center text-lg transition-colors ${
                    emoji === e ? 'bg-gold/20 border-2 border-gold' : 'bg-card border border-border'
                  }`}
                >
                  {e}
                </button>
              ))}
            </div>
            <Input placeholder="Habit name" value={name} onChange={(e) => setName(e.target.value)} className="bg-muted border-0" />
            <div className="flex gap-2">
              {(['daily', 'weekly'] as const).map((f) => (
                <button
                  key={f}
                  onClick={() => setFrequency(f)}
                  className={`flex-1 py-2 rounded-lg text-xs font-medium capitalize transition-colors ${
                    frequency === f ? 'bg-gold text-gold-foreground' : 'bg-card text-muted-foreground border border-border'
                  }`}
                >
                  {f}
                </button>
              ))}
            </div>
            <Button onClick={handleAdd} className="w-full bg-gold text-gold-foreground hover:bg-gold/90" disabled={!name.trim()}>
              Add Habit
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// JOURNAL SCREEN
// ═══════════════════════════════════════════════════════
function JournalScreen() {
  const { entries, addEntry, deleteEntry } = useJournalStore()
  const [showAddSheet, setShowAddSheet] = useState(false)
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [mood, setMood] = useState('happy')

  const selectedMood = MOODS.find(m => m.value === mood) || MOODS[0]

  const handleAdd = () => {
    if (!title.trim()) return
    addEntry({ title: title.trim(), content: content.trim(), mood: selectedMood.value, moodEmoji: selectedMood.emoji })
    setTitle(''); setContent(''); setMood('happy')
    setShowAddSheet(false)
  }

  const formatDate = (ts: number) => new Date(ts).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })

  return (
    <div className="flex flex-col h-full relative">
      <div className="flex-1 overflow-y-auto">
        {entries.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
            <BookOpen className="w-16 h-16 mb-4 opacity-40" />
            <p className="text-sm">No journal entries yet</p>
          </div>
        ) : (
          <div className="p-4 space-y-2.5">
            {entries.map((entry) => (
              <motion.div
                key={entry.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-card border border-border rounded-xl p-4"
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-lg">{entry.moodEmoji}</span>
                      <h3 className="text-sm font-bold text-foreground truncate">{entry.title}</h3>
                    </div>
                    {entry.content && <p className="text-xs text-muted-foreground line-clamp-2">{entry.content}</p>}
                    <p className="text-[10px] text-muted-foreground mt-2">{formatDate(entry.createdAt)}</p>
                  </div>
                  <button onClick={() => deleteEntry(entry.id)} className="text-red-500 ml-2 shrink-0">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>

      <button
        onClick={() => setShowAddSheet(true)}
        className="absolute bottom-4 right-4 w-12 h-12 rounded-full bg-gold shadow-lg shadow-gold/30 flex items-center justify-center"
      >
        <Plus className="w-6 h-6 text-gold-foreground" />
      </button>

      <Sheet open={showAddSheet} onOpenChange={setShowAddSheet}>
        <SheetContent side="bottom" className="rounded-t-2xl">
          <SheetHeader>
            <SheetTitle className="text-gold">New Journal Entry</SheetTitle>
          </SheetHeader>
          <div className="space-y-3 mt-4">
            <div>
              <p className="text-xs text-muted-foreground mb-2">How are you feeling?</p>
              <div className="flex gap-2 flex-wrap">
                {MOODS.map((m) => (
                  <button
                    key={m.value}
                    onClick={() => setMood(m.value)}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-colors ${
                      mood === m.value ? 'bg-gold text-gold-foreground' : 'bg-card border border-border text-muted-foreground'
                    }`}
                  >
                    <span>{m.emoji}</span> {m.label}
                  </button>
                ))}
              </div>
            </div>
            <Input placeholder="Title" value={title} onChange={(e) => setTitle(e.target.value)} className="bg-muted border-0" />
            <Textarea placeholder="What's on your mind?" value={content} onChange={(e) => setContent(e.target.value)} className="bg-muted border-0 min-h-[80px]" />
            <Button onClick={handleAdd} className="w-full bg-gold text-gold-foreground hover:bg-gold/90" disabled={!title.trim()}>
              Save Entry
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// MEMORY SCREEN
// ═══════════════════════════════════════════════════════
function MemoryScreen() {
  const { memories, addMemory, deleteMemory, searchQuery, setSearchQuery } = useMemoryStore()
  const [activeCategory, setActiveCategory] = useState('All')
  const [showSearch, setShowSearch] = useState(false)
  const [showAddSheet, setShowAddSheet] = useState(false)
  const [content, setContent] = useState('')
  const [category, setCategory] = useState('Personal')
  const [tags, setTags] = useState('')
  const [tagInput, setTagInput] = useState('')

  const filteredMemories = memories.filter(m => {
    const matchCategory = activeCategory === 'All' || m.category === activeCategory
    const matchSearch = !searchQuery || m.content.toLowerCase().includes(searchQuery.toLowerCase()) || m.tags.some(t => t.toLowerCase().includes(searchQuery.toLowerCase()))
    return matchCategory && matchSearch
  })

  const handleAdd = () => {
    if (!content.trim()) return
    const parsedTags = tags ? tags.split(',').map(t => t.trim()).filter(Boolean) : []
    addMemory({ content: content.trim(), category, tags: parsedTags })
    setContent(''); setTags(''); setCategory('Personal'); setTagInput('')
    setShowAddSheet(false)
  }

  const addTag = () => {
    if (tagInput.trim()) {
      setTags(tags ? `${tags}, ${tagInput.trim()}` : tagInput.trim())
      setTagInput('')
    }
  }

  const formatDate = (ts: number) => new Date(ts).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })

  const categoryColors: Record<string, string> = {
    Personal: 'bg-blue-500/20 text-blue-400',
    Work: 'bg-purple-500/20 text-purple-400',
    Learning: 'bg-green-500/20 text-green-400',
    Health: 'bg-red-500/20 text-red-400',
    Finance: 'bg-yellow-500/20 text-yellow-400',
    Social: 'bg-pink-500/20 text-pink-400',
  }

  return (
    <div className="flex flex-col h-full relative">
      <div className="flex-1 overflow-y-auto">
        {/* Search toggle */}
        <div className="px-4 pt-3 flex items-center gap-2">
          <button
            onClick={() => setShowSearch(!showSearch)}
            className="w-8 h-8 rounded-full bg-card border border-border flex items-center justify-center text-muted-foreground hover:text-foreground"
          >
            {showSearch ? <X className="w-4 h-4" /> : <Search className="w-4 h-4" />}
          </button>
        </div>

        {/* Search bar */}
        <AnimatePresence>
          {showSearch && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="px-4 overflow-hidden"
            >
              <Input
                placeholder="Search memories..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="bg-muted border-0 mt-2"
              />
            </motion.div>
          )}
        </AnimatePresence>

        {/* Category chips */}
        <div className="px-4 mt-2 flex gap-2 overflow-x-auto pb-2 scrollbar-none">
          <button
            onClick={() => setActiveCategory('All')}
            className={`shrink-0 px-3 py-1 rounded-full text-xs font-medium transition-colors ${
              activeCategory === 'All' ? 'bg-gold text-gold-foreground' : 'bg-card border border-border text-muted-foreground'
            }`}
          >
            All
          </button>
          {MEMORY_CATEGORIES.map((cat) => (
            <button
              key={cat}
              onClick={() => setActiveCategory(cat)}
              className={`shrink-0 px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                activeCategory === cat ? 'bg-gold text-gold-foreground' : 'bg-card border border-border text-muted-foreground'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Memories list */}
        {filteredMemories.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-[50vh] text-muted-foreground">
            <Brain className="w-16 h-16 mb-4 opacity-40" />
            <p className="text-sm">No memories yet</p>
          </div>
        ) : (
          <div className="p-4 space-y-2.5">
            {filteredMemories.map((mem) => (
              <motion.div
                key={mem.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-card border border-border rounded-xl p-4"
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-foreground">{mem.content}</p>
                    <div className="flex items-center gap-2 mt-2 flex-wrap">
                      <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium ${categoryColors[mem.category] || 'bg-muted text-muted-foreground'}`}>
                        {mem.category}
                      </span>
                      {mem.tags.map((t, i) => (
                        <Badge key={i} variant="secondary" className="text-[10px]">#{t}</Badge>
                      ))}
                    </div>
                    <p className="text-[10px] text-muted-foreground mt-2">{formatDate(mem.createdAt)}</p>
                  </div>
                  <button onClick={() => deleteMemory(mem.id)} className="text-red-500 ml-2 shrink-0">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>

      <button
        onClick={() => setShowAddSheet(true)}
        className="absolute bottom-4 right-4 w-12 h-12 rounded-full bg-gold shadow-lg shadow-gold/30 flex items-center justify-center"
      >
        <Plus className="w-6 h-6 text-gold-foreground" />
      </button>

      <Sheet open={showAddSheet} onOpenChange={setShowAddSheet}>
        <SheetContent side="bottom" className="rounded-t-2xl">
          <SheetHeader>
            <SheetTitle className="text-gold">Save Memory</SheetTitle>
          </SheetHeader>
          <div className="space-y-3 mt-4">
            <div>
              <p className="text-xs text-muted-foreground mb-2">Category:</p>
              <div className="flex gap-2 flex-wrap">
                {MEMORY_CATEGORIES.map((cat) => (
                  <button
                    key={cat}
                    onClick={() => setCategory(cat)}
                    className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                      category === cat ? 'bg-gold text-gold-foreground' : 'bg-card border border-border text-muted-foreground'
                    }`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>
            <Textarea placeholder="What do you want to remember?" value={content} onChange={(e) => setContent(e.target.value)} className="bg-muted border-0 min-h-[60px]" />
            <div>
              <p className="text-xs text-muted-foreground mb-2">Tags:</p>
              <div className="flex gap-2 mb-2">
                <Input
                  placeholder="Add tag"
                  value={tagInput}
                  onChange={(e) => setTagInput(e.target.value)}
                  onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addTag() } }}
                  className="bg-muted border-0 flex-1"
                />
                <Button size="sm" onClick={addTag} className="bg-gold text-gold-foreground shrink-0">
                  <Plus className="w-4 h-4" />
                </Button>
              </div>
              {tags && (
                <div className="flex flex-wrap gap-1">
                  {tags.split(',').map((t, i) => (
                    <Badge key={i} variant="secondary" className="text-[10px]">#{t.trim()}</Badge>
                  ))}
                </div>
              )}
            </div>
            <Button onClick={handleAdd} className="w-full bg-gold text-gold-foreground hover:bg-gold/90" disabled={!content.trim()}>
              Save Memory
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// CHARACTERS SCREEN
// ═══════════════════════════════════════════════════════
function CharactersScreen() {
  const { activeCharacter, customCharacters, allCharacters, setActiveCharacter, addCustomCharacter, removeCustomCharacter } = useCharacterStore()
  const [showAddSheet, setShowAddSheet] = useState(false)
  const [name, setName] = useState('')
  const [desc, setDesc] = useState('')
  const [system, setSystem] = useState('')
  const [emoji, setEmoji] = useState('🤖')
  const customEmojis = ['🤖', '👩‍🏫', '👨‍⚕️', '🧙', '🎭', '🦊', '🐱', '🌟', '🔥', '💎', '🦁', '🎯']

  const currentChar = allCharacters().find(c => c.name === activeCharacter) || BUILT_IN_CHARACTERS[0]

  const handleAdd = () => {
    if (!name.trim() || !system.trim()) return
    if (customCharacters.length >= 5) return
    addCustomCharacter({ name: name.trim(), emoji, desc: desc.trim(), system: system.trim() })
    setName(''); setDesc(''); setSystem(''); setEmoji('🤖')
    setShowAddSheet(false)
  }

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-y-auto">
        {/* Active character hero */}
        <div className="mx-4 mt-4 p-5 rounded-2xl border border-gold/40 bg-gradient-to-br from-gold/20 to-gold/5">
          <div className="flex items-center gap-4">
            <div className="w-20 h-20 rounded-full bg-gold/15 border-2 border-gold flex items-center justify-center shadow-lg shadow-gold/30 shrink-0">
              <span className="text-4xl">{currentChar.emoji}</span>
            </div>
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <h2 className="text-xl font-bold text-gold">{currentChar.name}</h2>
                <span className="text-[10px] px-2 py-0.5 rounded-md bg-gold/20 text-gold font-bold">Active Now</span>
              </div>
              <p className="text-xs text-muted-foreground mt-1.5 line-clamp-3">{currentChar.desc}</p>
            </div>
          </div>
        </div>

        {/* Characters grid */}
        <div className="grid grid-cols-2 gap-3 p-4">
          {allCharacters().map((char) => {
            const isActive = char.name === activeCharacter
            const isCustom = !BUILT_IN_CHARACTERS.some(b => b.name === char.name)
            return (
              <motion.button
                key={char.name}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                onClick={() => { if (!isActive) setActiveCharacter(char.name) }}
                className={`relative p-4 rounded-2xl border transition-all text-center ${
                  isActive
                    ? 'border-gold bg-gold/10 shadow-md shadow-gold/20'
                    : 'border-border bg-card hover:border-gold/30'
                }`}
              >
                {isActive && (
                  <div className="absolute top-2 right-2 w-5 h-5 rounded-full bg-gold flex items-center justify-center">
                    <Check className="w-3 h-3 text-gold-foreground" />
                  </div>
                )}
                {isCustom && (
                  <span className="absolute top-2 left-2 text-[9px] px-1.5 py-0.5 rounded bg-blue-500/20 text-blue-400">Custom</span>
                )}
                <div className={`w-14 h-14 mx-auto rounded-full flex items-center justify-center text-2xl mb-2 ${isActive ? 'bg-gold/15 border border-gold' : 'bg-muted'}`}>
                  {char.emoji}
                </div>
                <h3 className={`text-sm font-bold truncate ${isActive ? 'text-gold' : 'text-foreground'}`}>{char.name}</h3>
                <p className="text-[10px] text-muted-foreground mt-1 line-clamp-2">{char.desc}</p>
              </motion.button>
            )
          })}
        </div>

        {/* Add custom character */}
        {customCharacters.length < 5 && (
          <div className="px-4 pb-4">
            <button
              onClick={() => setShowAddSheet(true)}
              className="w-full h-14 rounded-xl border border-gold/30 bg-gold/5 flex items-center justify-center gap-2 text-gold hover:bg-gold/10 transition-colors"
            >
              <Plus className="w-5 h-5" />
              <span className="text-sm font-medium">Add Custom Character ({customCharacters.length}/5)</span>
            </button>
          </div>
        )}
      </div>

      <Sheet open={showAddSheet} onOpenChange={setShowAddSheet}>
        <SheetContent side="bottom" className="rounded-t-2xl">
          <SheetHeader>
            <SheetTitle className="text-gold">New Custom Character</SheetTitle>
          </SheetHeader>
          <div className="space-y-3 mt-4">
            <div className="flex justify-center">
              <div className="w-16 h-16 rounded-full bg-gold/10 border-2 border-gold flex items-center justify-center text-3xl">
                {emoji}
              </div>
            </div>
            <div className="flex flex-wrap gap-2 justify-center">
              {customEmojis.map((e) => (
                <button
                  key={e}
                  onClick={() => setEmoji(e)}
                  className={`w-10 h-10 rounded-xl flex items-center justify-center text-lg transition-colors ${
                    emoji === e ? 'bg-gold/20 border-2 border-gold' : 'bg-card border border-border'
                  }`}
                >
                  {e}
                </button>
              ))}
            </div>
            <Input placeholder="Character name" value={name} onChange={(e) => setName(e.target.value)} className="bg-muted border-0" />
            <Textarea placeholder="Short description" value={desc} onChange={(e) => setDesc(e.target.value)} className="bg-muted border-0 min-h-[40px]" />
            <Textarea placeholder="System instructions - How should it speak? What's its personality?" value={system} onChange={(e) => setSystem(e.target.value)} className="bg-muted border-0 min-h-[80px]" />
            <Button onClick={handleAdd} className="w-full bg-gold text-gold-foreground hover:bg-gold/90" disabled={!name.trim() || !system.trim()}>
              <Plus className="w-4 h-4 mr-2" /> Add Character
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}

// ═══════════════════════════════════════════════════════
// SETTINGS SCREEN
// ═══════════════════════════════════════════════════════
function SettingsScreen() {
  const { theme, setTheme } = useTheme()
  const { selectedModel, apiKeys, setSelectedModel, setApiKey, removeApiKey, resetApiKeys } = useSettingsStore()
  const [settingsTab, setSettingsTab] = useState('ai')
  const [editingKeys, setEditingKeys] = useState<Record<string, boolean>>({})
  const [keyValues, setKeyValues] = useState<Record<string, string>>({})
  const [obscured, setObscured] = useState<Record<string, boolean>>({})

  const isDark = theme === 'dark'
  const totalKeys = API_KEY_CONFIGS.length
  const activeKeys = API_KEY_CONFIGS.filter(c => apiKeys[c.key]?.length > 0).length

  const toggleEditing = (key: string, currentVal: string) => {
    setEditingKeys(prev => {
      const next = { ...prev, [key]: !prev[key] }
      if (!prev[key]) {
        setKeyValues(p => ({ ...p, [key]: currentVal }))
        setObscured(p => ({ ...p, [key]: true }))
      }
      return next
    })
  }

  const closeEditing = (key: string) => {
    setEditingKeys(prev => ({ ...prev, [key]: false }))
  }

  const handleDeleteKey = (key: string) => {
    removeApiKey(key)
    setEditingKeys(prev => ({ ...prev, [key]: false }))
    setKeyValues(prev => ({ ...prev, [key]: '' }))
  }

  const handleSaveKey = (key: string, value: string) => {
    if (value.trim()) {
      setApiKey(key, value.trim())
      setEditingKeys(prev => ({ ...prev, [key]: false }))
    }
  }

  const handleCopyStatus = () => {
    const info = `OWJ v3.0.0\nModel: ${selectedModel}\nActive Keys: ${activeKeys}/${totalKeys}\nTheme: ${theme}`
    navigator.clipboard.writeText(info)
  }

  const renderKeyTile = (config: typeof API_KEY_CONFIGS[0]) => {
    const isEditing = editingKeys[config.key] ?? false
    const value = keyValues[config.key] ?? ''
    const isObscured = obscured[config.key] ?? true
    const hasKey = apiKeys[config.key]?.length > 0
    const iconNode = ICON_MAP[config.icon]

    return (
      <div key={config.key} className="bg-card border rounded-xl mb-2 overflow-hidden" style={{ borderColor: hasKey ? 'rgba(34, 197, 94, 0.4)' : 'hsl(var(--border))' }}>
        <div className="flex items-center gap-3 px-3.5 py-2.5">
          <div className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 ${hasKey ? 'bg-green-500/10 text-green-500' : 'bg-muted text-muted-foreground'}`}>
            {iconNode}
          </div>
          <span className="flex-1 text-xs font-medium text-foreground">{config.label}</span>
          {hasKey && <Check className="w-4 h-4 text-green-500 shrink-0" />}
          <button
            onClick={() => toggleEditing(config.key, apiKeys[config.key] || '')}
            className={`text-[11px] px-2.5 py-1 rounded-md transition-colors ${
              isEditing ? 'bg-gold/15 text-gold' : 'bg-muted text-muted-foreground'
            }`}
          >
            {isEditing ? 'Close' : hasKey ? 'Edit' : 'Add'}
          </button>
        </div>
        {isEditing && (
          <div className="px-3.5 pb-3 space-y-2">
            <div className="relative">
              <input
                type={isObscured ? 'password' : 'text'}
                value={value}
                onChange={(e) => setKeyValues({ ...keyValues, [config.key]: e.target.value })}
                placeholder="Paste key here..."
                className="w-full rounded-lg bg-muted px-3 py-2 pr-8 text-xs text-foreground placeholder:text-muted-foreground outline-none font-mono"
              />
              <button
                onClick={() => setObscured({ ...obscured, [config.key]: !isObscured })}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground"
              >
                {isObscured ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
              </button>
            </div>
            <div className="flex gap-2">
              {hasKey && (
                <button
                  onClick={() => handleDeleteKey(config.key)}
                  className="flex items-center gap-1 px-3 py-1.5 rounded-lg border border-red-500/40 text-red-500 text-xs hover:bg-red-500/10"
                >
                  <Trash2 className="w-3 h-3" /> Delete
                </button>
              )}
              <button
                onClick={() => handleSaveKey(config.key, value)}
                className="flex items-center gap-1 px-4 py-1.5 rounded-lg bg-gold text-gold-foreground text-xs font-medium"
              >
                <Save className="w-3 h-3" /> Save
              </button>
            </div>
          </div>
        )}
      </div>
    )
  }

  const renderSectionHeader = (title: string) => (
    <div className="flex items-center gap-2 mb-2 mt-4 first:mt-0">
      <div className="w-1 h-4 rounded-sm bg-gold" />
      <span className="text-xs font-bold text-gold">{title}</span>
    </div>
  )

  return (
    <div className="flex flex-col h-full">
      <Tabs value={settingsTab} onValueChange={setSettingsTab} className="flex flex-col h-full">
        <TabsList className="w-full rounded-none bg-card border-b border-border h-11">
          <TabsTrigger value="ai" className="flex-1 gap-1 text-xs data-[state=active]:text-gold data-[state=active]:bg-transparent">
            <Cpu className="w-3.5 h-3.5" /> AI
          </TabsTrigger>
          <TabsTrigger value="keys" className="flex-1 gap-1 text-xs data-[state=active]:text-gold data-[state=active]:bg-transparent">
            <Key className="w-3.5 h-3.5" /> Keys
          </TabsTrigger>
          <TabsTrigger value="general" className="flex-1 gap-1 text-xs data-[state=active]:text-gold data-[state=active]:bg-transparent">
            <Settings className="w-3.5 h-3.5" /> General
          </TabsTrigger>
        </TabsList>

        {/* AI Tab */}
        <div className="flex-1 overflow-y-auto custom-scrollbar">
          {settingsTab === 'ai' && (
            <div className="p-4">
              {renderSectionHeader('Select Active Model')}
              <div className="space-y-2">
                {AI_PROVIDERS.map((provider) => {
                  const isSelected = selectedModel === provider
                  const storageKey = `api_key_${provider.toLowerCase()}`
                  const hasKey = apiKeys[storageKey]?.length > 0
                  const model = AI_MODELS[provider] || ''
                  const caps = MODEL_CAPABILITIES[provider] || []
                  const IconComp = PROVIDER_ICON_MAP[provider]
                  return (
                    <button
                      key={provider}
                      onClick={() => hasKey ? setSelectedModel(provider) : null}
                      className={`w-full flex items-center gap-3 p-3.5 rounded-xl border transition-all ${
                        isSelected
                          ? 'border-gold bg-gold/10'
                          : 'border-border bg-card hover:border-gold/30'
                      }`}
                    >
                      <div className={`w-11 h-11 rounded-full flex items-center justify-center shrink-0 ${
                        hasKey
                          ? isSelected ? 'bg-gold/20 text-gold' : 'bg-green-500/10 text-green-500'
                          : 'bg-muted text-muted-foreground'
                      }`}>
                        {IconComp}
                      </div>
                      <div className="flex-1 text-left min-w-0">
                        <div className="flex items-center gap-2">
                          <span className={`text-sm font-semibold ${isSelected ? 'text-gold' : hasKey ? 'text-foreground' : 'text-muted-foreground'}`}>
                            {provider}
                          </span>
                          {isSelected && (
                            <span className="text-[10px] px-2 py-0.5 rounded-md bg-gold/20 text-gold font-bold">Active</span>
                          )}
                        </div>
                        <p className="text-[11px] text-blue-400 mt-0.5">{model}</p>
                        <div className="flex flex-wrap gap-1 mt-1.5">
                          {caps.map((c) => (
                            <span key={c} className="text-[9px] px-1.5 py-0.5 rounded bg-muted text-muted-foreground">{c}</span>
                          ))}
                        </div>
                      </div>
                      <div className="shrink-0">
                        {!hasKey ? (
                          <Lock className="w-5 h-5 text-muted-foreground" />
                        ) : isSelected ? (
                          <Check className="w-6 h-6 text-gold" />
                        ) : (
                          <Radio className="w-5 h-5 text-green-500" />
                        )}
                      </div>
                    </button>
                  )
                })}
              </div>
              <div className="mt-4">
                {renderSectionHeader('Add Custom Models via OpenRouter')}
                <div className="p-3.5 rounded-xl bg-blue-500/10 border border-blue-500/30">
                  <div className="flex items-start gap-2.5">
                    <Info className="w-4 h-4 text-blue-400 shrink-0 mt-0.5" />
                    <p className="text-xs text-blue-400 leading-relaxed">
                      With an OpenRouter API key, you can access over 100 models including Claude and GPT-4.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Keys Tab */}
          {settingsTab === 'keys' && (
            <div className="p-4">
              {/* Status */}
              <div className="p-4 rounded-xl bg-gold/10 border border-gold/30 mb-4">
                <div className="flex items-center gap-4">
                  <div className="relative w-14 h-14 shrink-0">
                    <svg className="w-14 h-14 -rotate-90" viewBox="0 0 56 56">
                      <circle cx="28" cy="28" r="24" fill="none" stroke="hsl(var(--border))" strokeWidth="4" />
                      <circle cx="28" cy="28" r="24" fill="none" stroke="#D4A843" strokeWidth="4" strokeDasharray={`${(activeKeys / totalKeys) * 150.8} 150.8`} strokeLinecap="round" />
                    </svg>
                    <span className="absolute inset-0 flex items-center justify-center text-lg font-bold text-gold">{activeKeys}</span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold text-foreground">{activeKeys} of {totalKeys} keys active</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Each key enables a new feature</p>
                  </div>
                  <button
                    onClick={resetApiKeys}
                    className="text-xs text-gold font-medium shrink-0"
                  >
                    Reset
                  </button>
                </div>
              </div>

              {renderSectionHeader('AI Keys')}
              {AI_KEY_CONFIGS.map(renderKeyTile)}

              {renderSectionHeader('Search / Memory / Voice')}
              {SEARCH_MEMORY_KEYS.map(renderKeyTile)}

              {renderSectionHeader('Integrations')}
              {INTEGRATION_KEYS.map(renderKeyTile)}

              {renderSectionHeader('Firebase')}
              {FIREBASE_KEYS.map(renderKeyTile)}

              <div className="h-8" />
            </div>
          )}

          {/* General Tab */}
          {settingsTab === 'general' && (
            <div className="p-4">
              {/* App info card */}
              <div className="p-5 rounded-2xl bg-gradient-to-br from-gold/15 to-gold/5 border border-gold/30 mb-6">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-2xl bg-gold/20 flex items-center justify-center shrink-0">
                    <span className="text-xl font-bold text-gold">OWJ</span>
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-gold">OWJ - AI Mentor</h3>
                    <p className="text-xs text-muted-foreground mt-0.5">Version 3.0.0</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Made with ❤️</p>
                  </div>
                </div>
              </div>

              {renderSectionHeader('Appearance')}
              <div className="bg-card border border-border rounded-xl overflow-hidden">
                <div className="flex items-center gap-3 px-4 py-3">
                  <div className="w-9 h-9 rounded-full bg-gold/15 flex items-center justify-center text-gold shrink-0">
                    {isDark ? <Moon className="w-4 h-4" /> : <Sun className="w-4 h-4" />}
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-foreground">Dark Mode</p>
                    <p className="text-xs text-muted-foreground">{isDark ? 'Dark theme' : 'Light theme'}</p>
                  </div>
                  <Switch
                    checked={isDark}
                    onCheckedChange={(checked) => setTheme(checked ? 'dark' : 'light')}
                  />
                </div>
              </div>

              {renderSectionHeader('Data')}
              <button
                onClick={resetApiKeys}
                className="w-full flex items-center gap-3 p-3.5 rounded-xl bg-card border border-border mb-2"
              >
                <div className="w-9 h-9 rounded-full bg-blue-500/10 flex items-center justify-center text-blue-400 shrink-0">
                  <RotateCcw className="w-4 h-4" />
                </div>
                <div className="flex-1 text-left">
                  <p className="text-sm font-medium text-foreground">Reset API Keys</p>
                  <p className="text-xs text-muted-foreground">Restore all keys to default</p>
                </div>
                <ChevronRight className="w-4 h-4 text-muted-foreground" />
              </button>
              <button
                onClick={handleCopyStatus}
                className="w-full flex items-center gap-3 p-3.5 rounded-xl bg-card border border-border"
              >
                <div className="w-9 h-9 rounded-full bg-yellow-500/10 flex items-center justify-center text-yellow-400 shrink-0">
                  <Copy className="w-4 h-4" />
                </div>
                <div className="flex-1 text-left">
                  <p className="text-sm font-medium text-foreground">Copy System Status</p>
                  <p className="text-xs text-muted-foreground">Copy app info for diagnostics</p>
                </div>
                <ChevronRight className="w-4 h-4 text-muted-foreground" />
              </button>
              <div className="h-8" />
            </div>
          )}
        </div>
      </Tabs>
    </div>
  )
}
