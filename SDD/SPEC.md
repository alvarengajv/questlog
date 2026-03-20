# SPEC — Especificação Técnica · QuestLog

> **Stack:** Ruby on Rails 7.1 · PostgreSQL · Hotwire (Turbo + Stimulus) · TailwindCSS
> **Referência:** [PRD.md](file:///c:/Users/joaov/Documents/Projetos/Pessoais/v360-processo-seletivo/SDD/PRD.md) · [DECISIONS.md](file:///c:/Users/joaov/Documents/Projetos/Pessoais/v360-processo-seletivo/SDD/DECISIONS.md)

---

## 1. Arquivos a Criar

### 1.1 Models

| Arquivo | Responsabilidade |
|---------|-----------------|
| `app/models/user.rb` | Autenticação (`has_secure_password`), associações com listas e perfil de gamificação |
| `app/models/task_list.rb` | Lista de tarefas com cor, posição, arquivamento; scopes de filtro |
| `app/models/item.rb` | Item de tarefa com prioridade (enum), prazo, posição; lógica `overdue?` |
| `app/models/gamification_profile.rb` | Perfil 1:1 com User — XP, nível, streak |
| `app/models/achievement.rb` | Catálogo fixo de conquistas (seed) |
| `app/models/user_achievement.rb` | Junção N:N — conquistas desbloqueadas por usuário |
| `app/models/friendship.rb` | Relação N:N self-referencing entre usuários (pending/accepted) |

### 1.2 Controllers

| Arquivo | Responsabilidade |
|---------|-----------------|
| `app/controllers/application_controller.rb` | `current_user`, `require_authentication`, helper methods |
| `app/controllers/sessions_controller.rb` | Login (`new`, `create`) e logout (`destroy`) |
| `app/controllers/registrations_controller.rb` | Cadastro (`new`, `create`) |
| `app/controllers/task_lists_controller.rb` | CRUD de listas + `archive` / `restore` |
| `app/controllers/items_controller.rb` | CRUD de itens + `toggle` + `sort` (drag-and-drop) |
| `app/controllers/gamification_controller.rb` | Perfil do jogador e conquistas |
| `app/controllers/friendships_controller.rb` | Enviar, aceitar, recusar e remover amigos |
| `app/controllers/leaderboard_controller.rb` | Ranking de XP entre amigos |

### 1.3 Service Objects

| Arquivo | Responsabilidade |
|---------|-----------------|
| `app/services/gamification_service.rb` | Conceder XP, verificar level-up, checar conquistas, atualizar streak |
| `app/services/recurrence_service.rb` | Cria próximo item ao concluir item recorrente |

### 1.4 Views

| Arquivo | Responsabilidade |
|---------|-----------------|
| `app/views/layouts/application.html.erb` | Layout principal com navbar (logo, XP bar, streak, nível) |
| `app/views/sessions/new.html.erb` | Formulário de login |
| `app/views/registrations/new.html.erb` | Formulário de cadastro |
| `app/views/task_lists/index.html.erb` | Dashboard — cards de listas + seção "Arquivadas" |
| `app/views/task_lists/_task_list.html.erb` | Partial do card de lista (cor, progresso, ações) |
| `app/views/task_lists/_form.html.erb` | Partial do formulário de criação/edição de lista |
| `app/views/task_lists/show.html.erb` | Tela de lista — itens pendentes e concluídos |
| `app/views/items/_item.html.erb` | Partial de cada item (checkbox, badges, prazo, menu) |
| `app/views/items/_form.html.erb` | Partial do formulário inline de novo item |
| `app/views/gamification/show.html.erb` | Perfil de gamificação (XP, nível, streak, progresso) |
| `app/views/gamification/achievements.html.erb` | Grid de conquistas (desbloqueadas vs travadas) |
| `app/views/shared/_navbar.html.erb` | Navbar com gamification bar |
| `app/views/shared/_flash.html.erb` | Flash messages |
| `app/views/shared/_notifications.html.erb` | Container para toasts de conquista (Turbo Stream target) |
| `app/views/shared/_gamification_bar.html.erb` | Barra de XP + badge nível + streak (Turbo Stream target) |
| `app/views/friendships/index.html.erb` | Lista de amigos + convites pendentes |
| `app/views/friendships/_friendship.html.erb` | Partial de cada amigo (avatar, nível, XP) |
| `app/views/friendships/_invite_form.html.erb` | Formulário de convite por email |
| `app/views/leaderboard/index.html.erb` | Ranking de XP entre amigos |

### 1.5 Helpers

| Arquivo | Responsabilidade |
|---------|-----------------|
| `app/helpers/application_helper.rb` | Métodos genéricos de UI |
| `app/helpers/items_helper.rb` | `priority_badge(item)`, `due_date_class(item)`, `priority_color(priority)` |
| `app/helpers/gamification_helper.rb` | `xp_percentage(profile)`, `level_title(level)`, `streak_display(profile)` |

### 1.6 Stimulus Controllers (JavaScript)

| Arquivo | Responsabilidade |
|---------|-----------------|
| `app/javascript/controllers/sortable_controller.js` | Drag-and-drop via SortableJS — reordena itens e persiste via PATCH |
| `app/javascript/controllers/color_picker_controller.js` | Seletor de cor para listas |
| `app/javascript/controllers/flash_controller.js` | Auto-dismiss de flash messages e toasts |

### 1.7 Migrations

| Arquivo | Responsabilidade |
|---------|-----------------|
| `db/migrate/XXX_create_users.rb` | Tabela `users` |
| `db/migrate/XXX_create_task_lists.rb` | Tabela `task_lists` com FK para `users` |
| `db/migrate/XXX_create_items.rb` | Tabela `items` com FK para `task_lists` |
| `db/migrate/XXX_create_gamification_profiles.rb` | Tabela `gamification_profiles` com FK única para `users` |
| `db/migrate/XXX_create_achievements.rb` | Tabela `achievements` |
| `db/migrate/XXX_create_user_achievements.rb` | Tabela `user_achievements` com índice único composto |
| `db/migrate/XXX_create_friendships.rb` | Tabela `friendships` (self-referencing N:N) |

### 1.8 Seeds e Config

| Arquivo | Responsabilidade |
|---------|-----------------|
| `db/seeds.rb` | Seed das 10 conquistas do catálogo |
| `config/routes.rb` | Todas as rotas RESTful |

### 1.9 Testes (RSpec)

| Arquivo | Responsabilidade |
|---------|-----------------|
| `spec/models/user_spec.rb` | Validações, associações, `has_secure_password` |
| `spec/models/task_list_spec.rb` | Validações, scopes (`active`, `archived`), associações |
| `spec/models/item_spec.rb` | Validações, enum priority, `overdue?`, associações |
| `spec/models/gamification_profile_spec.rb` | Validações, cálculo de nível |
| `spec/models/achievement_spec.rb` | Validações |
| `spec/models/user_achievement_spec.rb` | Unicidade composta |
| `spec/models/friendship_spec.rb` | Validações, associações, scopes, unicidade |
| `spec/services/gamification_service_spec.rb` | XP, level-up, conquistas, streak |
| `spec/requests/sessions_spec.rb` | Login, logout, validação de credenciais |
| `spec/requests/registrations_spec.rb` | Cadastro, validações |
| `spec/requests/task_lists_spec.rb` | CRUD, archive, restore, scoped access |
| `spec/requests/items_spec.rb` | CRUD, toggle, sort, scoped access |
| `spec/requests/friendships_spec.rb` | Enviar, aceitar, recusar, remover |
| `spec/requests/leaderboard_spec.rb` | Ranking com e sem amigos |
| `spec/factories/users.rb` | Factory de User |
| `spec/factories/task_lists.rb` | Factory de TaskList |
| `spec/factories/items.rb` | Factory de Item |
| `spec/factories/gamification_profiles.rb` | Factory de GamificationProfile |
| `spec/factories/achievements.rb` | Factory de Achievement |

---

## 2. Models — Campos, Validações e Relacionamentos

### 2.1 User

```ruby
class User < ApplicationRecord
  has_secure_password

  has_many :task_lists, dependent: :destroy
  has_one  :gamification_profile, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements

  # Friendships (self-referencing)
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  has_many :pending_requests, -> { where(status: :pending) }, class_name: "Friendship", foreign_key: :friend_id

  validates :name,  presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  after_create :create_gamification_profile!

  def completed_items_count
    task_lists.joins(:items).where(items: { completed: true }).count
  end
end
```

**Campos da migration:**

| Campo | Tipo | Constraints |
|-------|------|------------|
| `name` | `string` | `null: false` |
| `email` | `string` | `null: false`, index unique |
| `password_digest` | `string` | `null: false` |
| `timestamps` | — | automático |

### 2.2 TaskList

```ruby
class TaskList < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy

  validates :title, presence: true, length: { maximum: 100 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }, allow_blank: true

  scope :active,   -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :ordered,  -> { order(:position) }
  scope :search,   ->(query) { where("title ILIKE ?", "%#{query}%") if query.present? }

  before_create :set_default_position

  def progress_percentage
    return 0 if items.count.zero?
    (items.completed.count.to_f / items.count * 100).round
  end

  def complete?
    items.any? && items.pending.empty?
  end

  private

  def set_default_position
    self.position ||= (user.task_lists.maximum(:position) || 0) + 1
  end
end
```

**Campos da migration:**

| Campo | Tipo | Constraints |
|-------|------|------------|
| `user_id` | `bigint` | `null: false`, FK `ON DELETE CASCADE`, index |
| `title` | `string` | `null: false` |
| `color` | `string` | default `"#4F46E5"` |
| `archived` | `boolean` | default `false`, `null: false` |
| `position` | `integer` | default `0` |
| `timestamps` | — | automático |

### 2.3 Item

```ruby
class Item < ApplicationRecord
  belongs_to :task_list

  enum :priority, { low: 0, medium: 1, high: 2 }, default: :low
  enum :recurrence, { none: 0, daily: 1, weekly: 2, monthly: 3 }, default: :none

  validates :title, presence: true, length: { maximum: 255 }
  validates :priority, inclusion: { in: priorities.keys }

  scope :completed, -> { where(completed: true) }
  scope :pending,   -> { where(completed: false) }
  scope :ordered,   -> { order(:position) }
  scope :by_priority, ->(p) { where(priority: p) if p.present? }

  before_create :set_default_position

  def overdue?
    due_date.present? && !completed? && due_date < Date.current
  end

  def due_today?
    due_date.present? && !completed? && due_date == Date.current
  end

  def recurring?
    recurrence != "none"
  end

  def xp_value
    case priority
    when "low"    then 5
    when "medium" then 10
    when "high"   then 20
    end
  end

  private

  def set_default_position
    self.position ||= (task_list.items.maximum(:position) || 0) + 1
  end
end
```

**Campos da migration:**

| Campo | Tipo | Constraints |
|-------|------|------------|
| `task_list_id` | `bigint` | `null: false`, FK `ON DELETE CASCADE`, index |
| `title` | `string` | `null: false` |
| `completed` | `boolean` | default `false`, `null: false` |
| `due_date` | `date` | nullable |
| `priority` | `integer` | default `0`, `null: false` |
| `recurrence` | `integer` | default `0` (none), `null: false` |
| `position` | `integer` | default `0` |
| `timestamps` | — | automático |

### 2.4 GamificationProfile

```ruby
class GamificationProfile < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :xp, numericality: { greater_than_or_equal_to: 0 }

  LEVELS = {
    1 => { min_xp: 0,    title: "Iniciante" },
    2 => { min_xp: 100,  title: "Organizado" },
    3 => { min_xp: 300,  title: "Produtivo" },
    4 => { min_xp: 600,  title: "Eficiente" },
    5 => { min_xp: 1000, title: "Mestre das Tasks" }
  }.freeze

  def recalculate_level!
    new_level = LEVELS.select { |_, v| xp >= v[:min_xp] }.keys.max
    update!(level: new_level)
  end

  def level_title
    LEVELS.dig(level, :title) || "Iniciante"
  end

  def xp_for_current_level
    LEVELS.dig(level, :min_xp) || 0
  end

  def xp_for_next_level
    LEVELS.dig(level + 1, :min_xp) || LEVELS.dig(level, :min_xp)
  end

  def xp_progress_percentage
    return 100 if level >= LEVELS.keys.max
    floor = xp_for_current_level
    ceiling = xp_for_next_level
    ((xp - floor).to_f / (ceiling - floor) * 100).round
  end
end
```

**Campos da migration:**

| Campo | Tipo | Constraints |
|-------|------|------------|
| `user_id` | `bigint` | `null: false`, FK `ON DELETE CASCADE`, index unique |
| `xp` | `integer` | default `0`, `null: false` |
| `level` | `integer` | default `1`, `null: false` |
| `current_streak` | `integer` | default `0`, `null: false` |
| `longest_streak` | `integer` | default `0`, `null: false` |
| `last_completed_at` | `date` | nullable |
| `timestamps` | — | automático |

### 2.5 Achievement

```ruby
class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements

  validates :key,   presence: true, uniqueness: true
  validates :title, presence: true
  validates :xp_reward, numericality: { greater_than_or_equal_to: 0 }
end
```

**Campos da migration:**

| Campo | Tipo | Constraints |
|-------|------|------------|
| `key` | `string` | `null: false`, index unique |
| `title` | `string` | `null: false` |
| `description` | `string` | |
| `icon` | `string` | |
| `xp_reward` | `integer` | default `0`, `null: false` |
| `timestamps` | — | automático |

### 2.6 UserAchievement

```ruby
class UserAchievement < ApplicationRecord
  belongs_to :user
  belongs_to :achievement

  validates :user_id, uniqueness: { scope: :achievement_id }
end
```

**Campos da migration:**

| Campo | Tipo | Constraints |
|-------|------|------------|
| `user_id` | `bigint` | `null: false`, FK `ON DELETE CASCADE` |
| `achievement_id` | `bigint` | `null: false`, FK |
| `unlocked_at` | `datetime` | `null: false` |
| `timestamps` | — | automático |

**Índice:** `add_index :user_achievements, [:user_id, :achievement_id], unique: true`

### 2.7 Friendship

```ruby
class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1 }, default: :pending

  validates :user_id, uniqueness: { scope: :friend_id, message: "já tem relação com este usuário" }
  validate :not_self_friend

  scope :accepted, -> { where(status: :accepted) }
  scope :pending_for, ->(user) { where(friend: user, status: :pending) }

  def accept!
    transaction do
      update!(status: :accepted)
      # Cria registro inverso para bidirecionalidade
      Friendship.find_or_create_by!(user: friend, friend: user) do |f|
        f.status = :accepted
      end
    end
  end

  private

  def not_self_friend
    errors.add(:friend_id, "não pode ser você mesmo") if user_id == friend_id
  end
end
```

**Campos da migration:**

| Campo | Tipo | Constraints |
|-------|------|------------|
| `user_id` | `bigint` | `null: false`, FK `ON DELETE CASCADE`, index |
| `friend_id` | `bigint` | `null: false`, FK `ON DELETE CASCADE` |
| `status` | `integer` | default `0` (pending), `null: false` |
| `timestamps` | — | automático |

**Índice:** `add_index :friendships, [:user_id, :friend_id], unique: true`

---

## 3. Controllers — Ações

### 3.1 ApplicationController

```ruby
class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    redirect_to login_path, alert: "Faça login para continuar." unless logged_in?
  end
end
```

### 3.2 SessionsController

| Ação | Método HTTP | Comportamento |
|------|-------------|---------------|
| `new` | GET `/login` | Renderiza formulário de login |
| `create` | POST `/login` | Autentica com `User.find_by(email:)&.authenticate(password)`. Sucesso → `session[:user_id]` + redirect `/task_lists`. Falha → re-renderiza `new` com flash de erro |
| `destroy` | DELETE `/logout` | `session.delete(:user_id)` → redirect `/login` |

### 3.3 RegistrationsController

| Ação | Método HTTP | Comportamento |
|------|-------------|---------------|
| `new` | GET `/signup` | Renderiza formulário de cadastro |
| `create` | POST `/signup` | Cria `User` → `session[:user_id]` → redirect `/task_lists`. Falha → re-renderiza `new` com erros |

### 3.4 TaskListsController

**Before action:** `require_authentication` em todas. Escopo sempre via `current_user.task_lists`.

| Ação | Método HTTP | Comportamento |
|------|-------------|---------------|
| `index` | GET `/task_lists` | `@active_lists = current_user.task_lists.active.ordered`; `@archived_lists = current_user.task_lists.archived.ordered`. Aceita `params[:search]` para filtro por título |
| `create` | POST `/task_lists` | Cria lista. Sucesso → responde com Turbo Stream (`prepend` no `#task_lists`). Falha → Turbo Stream com erros |
| `show` | GET `/task_lists/:id` | `@task_list` + `@pending_items` + `@completed_items`. Aceita `params[:priority]` para filtro |
| `update` | PATCH `/task_lists/:id` | Atualiza título/cor. Turbo Stream `replace` |
| `destroy` | DELETE `/task_lists/:id` | Exclui lista. Turbo Stream `remove` |
| `archive` | PATCH `/task_lists/:id/archive` | `@task_list.update!(archived: true)`. Turbo Stream `remove` do dashboard ativo |
| `restore` | PATCH `/task_lists/:id/restore` | `@task_list.update!(archived: false)`. Turbo Stream `prepend` no dashboard ativo |

### 3.5 ItemsController

**Before action:** `require_authentication`. Escopo: `current_user.task_lists.find(params[:task_list_id]).items`.

| Ação | Método HTTP | Comportamento |
|------|-------------|---------------|
| `create` | POST `/task_lists/:task_list_id/items` | Cria item. Turbo Stream `append` em `#items`. Checa conquista `first_task` e `first_list` via `GamificationService` |
| `update` | PATCH `/task_lists/:task_list_id/items/:id` | Atualiza título, prioridade, prazo. Turbo Stream `replace` |
| `destroy` | DELETE `/task_lists/:task_list_id/items/:id` | Exclui item. Turbo Stream `remove` |
| `toggle` | PATCH `/task_lists/:task_list_id/items/:id/toggle` | Inverte `completed`. Se concluindo → chama `GamificationService.call(user, item)`. Turbo Stream `replace` item + `replace` gamification bar + `append` toast de conquista (se houver) |
| `sort` | PATCH `/task_lists/:task_list_id/items/sort` | Recebe `params[:ids]` (array ordenado). Atualiza `position` de cada item |

### 3.6 GamificationController

**Before action:** `require_authentication`.

| Ação | Método HTTP | Comportamento |
|------|-------------|---------------|
| `show` | GET `/profile` | `@profile = current_user.gamification_profile`. Exibe XP, nível, streak, progresso |
| `achievements` | GET `/profile/achievements` | `@all = Achievement.all`; `@unlocked = current_user.achievements`. Grid com estado visual (desbloqueada/travada) |

### 3.7 FriendshipsController

**Before action:** `require_authentication`.

| Ação | Método HTTP | Comportamento |
|------|-------------|---------------|
| `index` | GET `/friends` | Lista amigos aceitos + convites pendentes recebidos |
| `create` | POST `/friends` | Busca user por email, cria `Friendship` com status `pending`. Se não encontrar → flash de erro |
| `accept` | PATCH `/friends/:id/accept` | Chama `friendship.accept!` (cria registro bidirecional). Turbo Stream replace |
| `destroy` | DELETE `/friends/:id` | Remove amizade (e o registro inverso se aceita). Turbo Stream remove |

### 3.8 LeaderboardController

**Before action:** `require_authentication`.

| Ação | Método HTTP | Comportamento |
|------|-------------|---------------|
| `index` | GET `/leaderboard` | `@ranking` = amigos aceitos + current_user, ordenados por XP desc. Inclui posição, nível e streak |

---

## 4. Rotas

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Autenticação
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get  "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  # Listas + Itens
  resources :task_lists, except: [:new, :edit] do
    member do
      patch :archive
      patch :restore
    end
    resources :items, only: [:create, :update, :destroy] do
      member do
        patch :toggle
      end
      collection do
        patch :sort
      end
    end
  end

  # Gamificação
  get "profile",              to: "gamification#show"
  get "profile/achievements", to: "gamification#achievements"

  # Amizades + Ranking
  resources :friends, controller: "friendships", only: [:index, :create, :destroy] do
    member do
      patch :accept
    end
  end
  get "leaderboard", to: "leaderboard#index"

  # Root
  root "task_lists#index"
end
```

**Tabela de rotas geradas:**

| Método | Path | Controller#Action |
|--------|------|-------------------|
| GET | `/login` | `sessions#new` |
| POST | `/login` | `sessions#create` |
| DELETE | `/logout` | `sessions#destroy` |
| GET | `/signup` | `registrations#new` |
| POST | `/signup` | `registrations#create` |
| GET | `/task_lists` | `task_lists#index` |
| POST | `/task_lists` | `task_lists#create` |
| GET | `/task_lists/:id` | `task_lists#show` |
| PATCH | `/task_lists/:id` | `task_lists#update` |
| DELETE | `/task_lists/:id` | `task_lists#destroy` |
| PATCH | `/task_lists/:id/archive` | `task_lists#archive` |
| PATCH | `/task_lists/:id/restore` | `task_lists#restore` |
| POST | `/task_lists/:id/items` | `items#create` |
| PATCH | `/task_lists/:id/items/:id` | `items#update` |
| DELETE | `/task_lists/:id/items/:id` | `items#destroy` |
| PATCH | `/task_lists/:id/items/:id/toggle` | `items#toggle` |
| PATCH | `/task_lists/:id/items/sort` | `items#sort` |
| GET | `/profile` | `gamification#show` |
| GET | `/profile/achievements` | `gamification#achievements` |
| GET | `/friends` | `friendships#index` |
| POST | `/friends` | `friendships#create` |
| DELETE | `/friends/:id` | `friendships#destroy` |
| PATCH | `/friends/:id/accept` | `friendships#accept` |
| GET | `/leaderboard` | `leaderboard#index` |
| GET | `/` | `task_lists#index` |

---

## 5. Views / Frontend

### 5.1 Layout (`application.html.erb`)

- HTML5 semântico, metatags, Tailwind, Turbo
- `<body>` com `<%= render "shared/navbar" %>` + `<main>` + `<%= render "shared/notifications" %>`
- Navbar: logo "QuestLog", se logado: gamification bar + logout; se deslogado: links login/signup

### 5.2 Navbar (`_navbar.html.erb`)

```erb
<%# Turbo Frame para atualização parcial da gamification bar %>
<nav class="...">
  <a href="<%= root_path %>">QuestLog</a>
  <% if logged_in? %>
    <turbo-frame id="gamification_bar">
      <%= render "shared/gamification_bar", profile: current_user.gamification_profile %>
    </turbo-frame>
    <%= button_to "Sair", logout_path, method: :delete %>
  <% end %>
</nav>
```

### 5.3 Gamification Bar (`_gamification_bar.html.erb`)

Exibe: emoji 🔥 + `current_streak` + badge nível (`Nv.X Título`) + barra XP (progress bar com % preenchida) + total XP.

### 5.4 Dashboard (`task_lists/index.html.erb`)

- Título "Minhas Listas" + botão "+ Nova Lista" (abre formulário inline via Turbo Frame)
- `<turbo-frame id="new_task_list">` com `_form.html.erb`
- `<div id="task_lists">` → `<%= render @active_lists %>`
- Seção "Arquivadas" colapsável → `<%= render @archived_lists %>`

### 5.5 Card de Lista (`_task_list.html.erb`)

```erb
<turbo-frame id="<%= dom_id(task_list) %>">
  <div class="..." style="border-left: 4px solid <%= task_list.color %>">
    <h3><%= task_list.title %></h3>
    <%# Barra de progresso %>
    <div class="progress-bar">
      <div style="width: <%= task_list.progress_percentage %>%"></div>
    </div>
    <span><%= task_list.items.completed.count %>/<%= task_list.items.count %></span>
    <%# Ações: Editar, Arquivar/Restaurar, Excluir %>
  </div>
</turbo-frame>
```

### 5.6 Show Lista (`task_lists/show.html.erb`)

- Link "← Voltar" para dashboard
- Título com cor da lista + botões "Editar" e "Arquivar"
- Barra de progresso com percentual
- Formulário inline para novo item (Turbo Frame `new_item`)
- Seção "Pendentes" → itens `pending.ordered` com drag-and-drop (Stimulus `sortable`)
- Seção "Concluídos" → itens `completed.ordered` com strikethrough

### 5.7 Item (`_item.html.erb`)

```erb
<turbo-frame id="<%= dom_id(item) %>">
  <div class="..." data-controller="..." data-item-id="<%= item.id %>">
    <%= button_to toggle_task_list_item_path(item.task_list, item),
        method: :patch do %>
      <%= item.completed? ? "☑" : "☐" %>
    <% end %>
    <span class="<%= 'line-through opacity-50' if item.completed? %>">
      <%= priority_badge(item) %> <%= item.title %>
    </span>
    <% if item.due_date %>
      <span class="<%= due_date_class(item) %>">
        📅 <%= item.due_date.strftime("%d/%m") %>
      </span>
    <% end %>
    <%# Menu dropdown: Editar, Excluir %>
  </div>
</turbo-frame>
```

### 5.8 Toast de Conquista (via Turbo Stream)

Quando `GamificationService` desbloqueia uma conquista, o controller responde com Turbo Stream `append` em `#notifications`:

```erb
<turbo-stream action="append" target="notifications">
  <template>
    <div class="toast achievement-toast" data-controller="flash">
      🏆 Conquista desbloqueada: <strong><%= achievement.title %></strong>
      <small>+<%= achievement.xp_reward %> XP</small>
    </div>
  </template>
</turbo-stream>
```

### 5.9 Animação +XP

Ao concluir item, Turbo Stream `append` em `#notifications` com animação CSS de texto flutuante `+X XP` que sobe e desaparece.

---

## 6. Service Object — GamificationService

### 6.1 Interface

```ruby
class GamificationService
  Result = Struct.new(:xp_earned, :leveled_up, :new_level, :achievements_unlocked, keyword_init: true)

  def initialize(user, item = nil)
    @user = user
    @item = item
    @profile = user.gamification_profile
    @unlocked = []
    @xp_earned = 0
  end

  def self.call(user, item = nil)
    new(user, item).call
  end

  def call
    return Result.new(xp_earned: 0, leveled_up: false, achievements_unlocked: []) unless @item&.completed?

    grant_item_xp
    grant_on_time_bonus
    grant_list_complete_bonus
    update_streak
    check_achievements
    level_up = @profile.recalculate_level!

    Result.new(
      xp_earned: @xp_earned,
      leveled_up: level_up,
      new_level: @profile.level,
      achievements_unlocked: @unlocked
    )
  end
end
```

### 6.2 Métodos Internos (Pseudocódigo)

```ruby
private

def grant_item_xp
  xp = @item.xp_value  # 5, 10 ou 20 baseado na prioridade
  @profile.increment!(:xp, xp)
  @xp_earned += xp
end

def grant_on_time_bonus
  return unless @item.due_date.present? && @item.due_date >= Date.current
  @profile.increment!(:xp, 5)
  @xp_earned += 5
end

def grant_list_complete_bonus
  return unless @item.task_list.complete?
  @profile.increment!(:xp, 30)
  @xp_earned += 30
end

def update_streak
  today = Date.current
  if @profile.last_completed_at == today - 1.day
    @profile.increment!(:current_streak)
  elsif @profile.last_completed_at != today
    @profile.update!(current_streak: 1)
  end
  # Atualiza recorde
  if @profile.current_streak > @profile.longest_streak
    @profile.update!(longest_streak: @profile.current_streak)
  end
  @profile.update!(last_completed_at: today)
  # XP de streak
  @profile.increment!(:xp, 10)
  @xp_earned += 10
end

def check_achievements
  check_and_unlock("first_task")    { completed_count >= 1 }
  check_and_unlock("ten_tasks")     { completed_count >= 10 }
  check_and_unlock("fifty_tasks")   { completed_count >= 50 }
  check_and_unlock("first_list")    { @user.task_lists.count >= 1 }
  check_and_unlock("list_complete") { @item.task_list.complete? }
  check_and_unlock("streak_3")      { @profile.current_streak >= 3 }
  check_and_unlock("streak_7")      { @profile.current_streak >= 7 }
  check_and_unlock("streak_30")     { @profile.current_streak >= 30 }
  check_and_unlock("high_priority") { completed_high_priority_count >= 10 }
  check_and_unlock("on_time")       { completed_on_time_count >= 5 }
end

def check_and_unlock(key, &condition)
  return if @user.achievements.exists?(key: key)
  achievement = Achievement.find_by(key: key)
  return unless achievement && condition.call

  @user.user_achievements.create!(achievement: achievement, unlocked_at: Time.current)
  @profile.increment!(:xp, achievement.xp_reward)
  @xp_earned += achievement.xp_reward
  @unlocked << achievement
end

def completed_count
  @completed_count ||= @user.completed_items_count
end

def completed_high_priority_count
  @user.task_lists.joins(:items).where(items: { completed: true, priority: :high }).count
end

def completed_on_time_count
  @user.task_lists.joins(:items)
    .where(items: { completed: true })
    .where("items.due_date >= items.updated_at::date")
    .count
end
```

---

## 7. Passo a Passo de Implementação

### Fase 1 — Setup do projeto

1. `rails new questlog -d postgresql -c tailwind --skip-jbuilder --skip-mailer --skip-action-mailbox --skip-action-cable`
2. Configurar `database.yml` para PostgreSQL local
3. Adicionar gems ao `Gemfile`: `bcrypt`, `rspec-rails`, `factory_bot_rails`, `faker`
4. `bundle install`
5. `rails generate rspec:install`
6. `rails db:create`

### Fase 2 — Autenticação

7. Criar migration e model `User` com validações
8. Implementar `ApplicationController` (`current_user`, `require_authentication`)
9. Implementar `SessionsController` (login/logout)
10. Implementar `RegistrationsController` (cadastro)
11. Criar views de login e signup
12. Configurar rotas de autenticação
13. Escrever testes de model e request para User/Sessions/Registrations

### Fase 3 — CRUD de listas

14. Criar migration e model `TaskList` com validações e scopes
15. Implementar `TaskListsController` (index, create, show, update, destroy)
16. Criar views: dashboard (index), show, partials (_task_list, _form)
17. Implementar Turbo Streams para create/update/destroy
18. Implementar archive/restore com Turbo Streams
19. Implementar busca por título (scope `search`)
20. Escrever testes

### Fase 4 — CRUD de itens

21. Criar migration e model `Item` com validações, enum, scopes
22. Implementar `ItemsController` (create, update, destroy, toggle)
23. Criar partials (_item, _form)
24. Implementar Turbo Streams para todas as ações de item
25. Implementar badges de prioridade e destaque de prazo via helpers
26. Escrever testes

### Fase 5 — Drag-and-drop

27. Instalar SortableJS: `bin/importmap pin sortablejs`
28. Criar Stimulus controller `sortable_controller.js`
29. Implementar ação `items#sort` no controller
30. Testar reordenação

### Fase 6 — Gamificação

31. Criar migrations para `gamification_profiles`, `achievements`, `user_achievements`
32. Implementar models com validações e associações
33. Criar `db/seeds.rb` com as 10 conquistas
34. Implementar `GamificationService`
35. Integrar service no `ItemsController#toggle`
36. Criar `GamificationController` (show, achievements)
37. Implementar Turbo Stream para gamification bar e toasts
38. Implementar views de perfil e conquistas
39. Escrever testes do service e controller

### Fase 7 — Layout e polish

40. Implementar layout completo com navbar e gamification bar
41. Criar Stimulus controllers (color_picker, flash)
42. Adicionar animações CSS (toast, +XP flutuante, hover em cards)
43. Implementar filtros de itens por prioridade
44. Responsividade mobile

### Fase 8 — Testes finais

45. Rodar `bundle exec rspec` — todos os testes verdes
46. Testar manualmente todos os fluxos
47. Revisar código e documentação

---

## 8. Pseudocódigo dos Fluxos Principais

### 8.1 Login

```
FUNCTION sessions#create(email, password)
  user = User.find_by(email: normalize(email))
  IF user AND user.authenticate(password)
    session[:user_id] = user.id
    REDIRECT to task_lists_path with notice "Bem-vindo!"
  ELSE
    flash.now[:alert] = "Email ou senha inválidos."
    RENDER :new, status: :unprocessable_entity
  END
END
```

### 8.2 Cadastro

```
FUNCTION registrations#create(name, email, password, password_confirmation)
  user = User.new(name:, email:, password:, password_confirmation:)
  IF user.save
    session[:user_id] = user.id
    REDIRECT to task_lists_path with notice "Conta criada com sucesso!"
  ELSE
    RENDER :new, status: :unprocessable_entity
  END
END
```

### 8.3 Criar Lista

```
FUNCTION task_lists#create(title, color)
  @task_list = current_user.task_lists.build(title:, color:)
  IF @task_list.save
    RESPOND with Turbo Stream: prepend @task_list to #task_lists
  ELSE
    RESPOND with Turbo Stream: replace #new_task_list_form with errors
  END
END
```

### 8.4 Toggle Item (fluxo principal de gamificação)

```
FUNCTION items#toggle(task_list_id, id)
  @task_list = current_user.task_lists.find(task_list_id)
  @item = @task_list.items.find(id)
  @item.update!(completed: !@item.completed)

  IF @item.completed?
    result = GamificationService.call(current_user, @item)
    @new_item = RecurrenceService.call(@item)  # nil se não recorrente
  END

  RESPOND with Turbo Stream:
    1. REPLACE #item_{id} with updated partial
    2. REPLACE #gamification_bar with updated bar
    3. FOR EACH achievement IN result.achievements_unlocked
         APPEND toast to #notifications
       END
    4. IF result.xp_earned > 0
         APPEND "+#{result.xp_earned} XP" animation to #notifications
       END
    5. IF @new_item present?
         APPEND @new_item to #items
         APPEND toast "Próxima ocorrência criada para #{@new_item.due_date}" to #notifications
       END
END
```

### 8.5 Drag-and-drop (Stimulus)

```
// sortable_controller.js
CONNECT:
  Initialize SortableJS on this.element
  options: animation 150, handle ".drag-handle", onEnd: this.updatePositions

FUNCTION updatePositions(event):
  ids = Array.from(this.element.children).map(el => el.dataset.itemId)
  FETCH PATCH /task_lists/{task_list_id}/items/sort
    body: { ids: ids }
    headers: { X-CSRF-Token, Content-Type: application/json }
END
```

### 8.6 GamificationService (resumo)

```
FUNCTION GamificationService.call(user, item)
  RETURN empty_result IF item is not completed

  profile = user.gamification_profile
  xp = 0

  # 1. XP base por prioridade
  xp += item.xp_value  (5 | 10 | 20)

  # 2. Bônus por prazo
  IF item has due_date AND due_date >= today
    xp += 5
  END

  # 3. Bônus por lista completa
  IF item.task_list has no pending items
    xp += 30
  END

  # 4. Streak
  IF last_completed_at == yesterday
    profile.current_streak += 1
  ELSIF last_completed_at != today
    profile.current_streak = 1
  END
  Update longest_streak if current > longest
  profile.last_completed_at = today
  xp += 10  (streak bonus diário)

  # 5. Aplicar XP
  profile.xp += xp

  # 6. Recalcular nível
  profile.recalculate_level!

  # 7. Checar conquistas
  FOR EACH achievement_definition
    IF not already unlocked AND condition met
      Create user_achievement
      profile.xp += achievement.xp_reward
      Add to unlocked list
    END
  END

  RETURN Result(xp_earned, leveled_up, new_level, achievements_unlocked)
END
```

### 8.7 RecurrenceService (resumo)

```
FUNCTION RecurrenceService.call(item)
  RETURN nil IF item.recurrence == "none"
  RETURN nil IF NOT item.completed?

  base_date = item.due_date || Date.current

  next_date = CASE item.recurrence
    WHEN "daily"   THEN base_date + 1.day
    WHEN "weekly"  THEN base_date + 1.week
    WHEN "monthly" THEN base_date + 1.month
  END

  new_item = item.task_list.items.create!(
    title:      item.title,
    priority:   item.priority,
    recurrence: item.recurrence,
    due_date:   next_date,
    completed:  false
  )

  RETURN new_item
END
```

---

## 9. Boas Práticas a Seguir

### Segurança

- **Scoped queries sempre:** `current_user.task_lists.find(id)` — nunca `TaskList.find(id)`. Impede acesso cross-user.
- **Strong parameters:** Whitelist explícita em cada controller.
- **`has_secure_password`:** Hash bcrypt automático. Nunca armazenar senha em texto plano.
- **CSRF:** Token automático do Rails em formulários. Para requests JS (drag-and-drop), enviar `X-CSRF-Token` no header.
- **Validações no banco E no model:** Constraints `NOT NULL`, `UNIQUE` e `FK ON DELETE CASCADE` no banco como rede de segurança.

### Arquitetura

- **Fat model, skinny controller:** Scopes, validações e métodos de domínio nos models. Controllers orquestram.
- **Service Object para lógica cross-model:** `GamificationService` encapsula XP + conquistas + streak.
- **Sem callbacks para gamificação:** Chamada explícita no controller após `toggle` — evita efeitos colaterais em outros contextos (ex: drag-and-drop).
- **Helpers para lógica de apresentação:** `priority_badge`, `due_date_class`, `xp_percentage` — nunca lógica nas views.

### Performance

- **Índices em FKs:** `user_id`, `task_list_id` indexados para JOINs rápidos.
- **Counter cache (opcional):** `items_count` em `TaskList` para evitar `COUNT(*)` no dashboard.
- **`includes`/`preload`:** Eager loading de associações no controller para evitar N+1.
- **Enum como integer:** `priority` no banco como int (0, 1, 2) — mais performático que string.

### Testes

- **RSpec + FactoryBot:** Factories para cada model, traits para variações.
- **Model specs:** Validações, scopes, métodos de domínio, associações.
- **Request specs:** Fluxos HTTP completos — autenticação, CRUD, scoped access.
- **Service specs:** XP calculation, level-up, streak logic, achievement unlock.
- **Cobertura:** Todos os fluxos do PRD devem ter pelo menos 1 teste.

### Código Limpo

- **Naming claro:** `overdue?`, `complete?`, `progress_percentage` — métodos autoexplicativos.
- **DRY:** Partials para cards e itens. Helper methods para badges.
- **Convenções Rails:** Seguir Rails Way (MVC, RESTful routes, ActiveRecord pattern).
- **Seeds reproduzíveis:** `find_or_create_by` para idempotência em `seeds.rb`.

### UX / Hotwire

- **Turbo Frames:** Para edição inline (item, lista) sem navegação.
- **Turbo Streams:** Para append/remove/replace em tempo real.
- **Stimulus:** Apenas para JS necessário — SortableJS, color picker, flash auto-dismiss.
- **Feedback imediato:** Toda ação do usuário tem resposta visual < 100ms (Turbo Stream) e feedback explícito (+XP, toast).

---

## 10. Seeds (Conquistas)

```ruby
# db/seeds.rb
achievements = [
  { key: "first_task",    title: "Primeira Tarefa",    description: "Concluir 1 item",                       icon: "✅", xp_reward: 10  },
  { key: "ten_tasks",     title: "Dez de Dez",         description: "Concluir 10 itens",                     icon: "🔟", xp_reward: 25  },
  { key: "fifty_tasks",   title: "Meio Centenário",    description: "Concluir 50 itens",                     icon: "🏅", xp_reward: 50  },
  { key: "first_list",    title: "Listeiro",           description: "Criar primeira lista",                  icon: "📋", xp_reward: 10  },
  { key: "list_complete", title: "Missão Cumprida",    description: "Completar 100% de uma lista",           icon: "🎯", xp_reward: 30  },
  { key: "streak_3",      title: "Constância",         description: "3 dias consecutivos",                   icon: "🔥", xp_reward: 20  },
  { key: "streak_7",      title: "Semana Produtiva",   description: "7 dias consecutivos",                   icon: "📆", xp_reward: 50  },
  { key: "streak_30",     title: "Maratonista",        description: "30 dias consecutivos",                  icon: "🏆", xp_reward: 150 },
  { key: "high_priority", title: "Prioridade Máxima",  description: "Concluir 10 itens de alta prioridade",  icon: "🔴", xp_reward: 40  },
  { key: "on_time",       title: "Pontualidade",       description: "Concluir 5 itens antes do prazo",       icon: "⏰", xp_reward: 30  }
]

achievements.each do |attrs|
  Achievement.find_or_create_by!(key: attrs[:key]) do |a|
    a.title       = attrs[:title]
    a.description = attrs[:description]
    a.icon        = attrs[:icon]
    a.xp_reward   = attrs[:xp_reward]
  end
end

puts "✅ #{Achievement.count} conquistas criadas/verificadas."
```
