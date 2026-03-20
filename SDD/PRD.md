# PRD — QuestLog

> Aplicação web de gerenciamento de listas de tarefas
> **Stack:** Ruby on Rails 7.1 · PostgreSQL · Hotwire · TailwindCSS

---

## 1. Visão do Produto

**QuestLog** é um gerenciador de listas de tarefas com **gamificação**. O usuário cria listas, adiciona itens com prioridade e prazo, acompanha progresso — e ganha **XP, níveis e conquistas** conforme conclui tarefas. Produtividade vira jogo.

**Público-alvo:** Qualquer pessoa que precise organizar tarefas — listas de compras, checklists de estudo, rotinas de trabalho — e que se motive por feedback visual e recompensas.

**Proposta de valor:** Simplicidade com acabamento e motivação. Uma app que faz o básico muito bem feito, com detalhes de UX que demonstram cuidado (progresso visual, drag-and-drop, atualização sem reload) e uma camada de **gamificação** que incentiva o uso contínuo.

---

## 2. Funcionalidades

### Essenciais (escopo mínimo)

| Funcionalidade               | Descrição                                                    |
|------------------------------|--------------------------------------------------------------|
| Cadastro e login             | Email + senha, autenticação via `has_secure_password`        |
| CRUD de listas               | Criar, editar, excluir listas de tarefas                     |
| CRUD de itens                | Criar, editar, excluir itens dentro de uma lista             |
| Marcar como concluído        | Toggle checkbox, itens concluídos vão para o final da lista  |

### Diferenciais (detalhados na seção 6)

| Funcionalidade               | Complexidade | Impacto |
|------------------------------|:---:|:---:|
| Cores personalizadas         | Baixa  | Alto   |
| Prioridade com badges        | Baixa  | Médio  |
| Prazo com destaque visual    | Baixa  | Médio  |
| Barra de progresso           | Baixa  | Alto   |
| Arquivamento de listas       | Baixa  | Médio  |
| Drag-and-drop                | Média  | Alto   |
| Hotwire (Turbo Streams)      | Média  | Alto   |
| Busca e filtros              | Média  | Médio  |
| 🎮 Gamificação (XP + Níveis) | Média  | Alto   |
| 🏆 Conquistas (Achievements) | Média  | Alto   |
| 🔥 Streaks diários           | Baixa  | Alto   |
| 👥 Ranking entre amigos      | Média  | Alto   |
| 🔁 Tarefas recorrentes       | Média  | Alto   |

---

## 3. Modelagem de Dados

### Entidades e relacionamentos

```
User (1) ──▶ (N) TaskList (1) ──▶ (N) Item
  │
  ├── (1) ──▶ (1) GamificationProfile
  ├── (1) ──▶ (N) UserAchievement (N) ◀── (1) Achievement
  └── (1) ──▶ (N) Friendship (N) ◀── (1) User
```

Sete tabelas: `users`, `task_lists`, `items`, `gamification_profiles`, `achievements`, `user_achievements` e `friendships`.

### Users

| Campo             | Tipo     | Regras                              |
|-------------------|----------|-------------------------------------|
| name              | string   | Obrigatório                         |
| email             | string   | Obrigatório, único, formato válido  |
| password_digest   | string   | Mínimo 6 caracteres, hash bcrypt   |

> O perfil de gamificação é separado em tabela própria (1:1) para não poluir a tabela `users`.

### Task Lists

| Campo     | Tipo     | Regras                                    |
|-----------|----------|-------------------------------------------|
| user_id   | FK       | Obrigatório · `ON DELETE CASCADE`         |
| title     | string   | Obrigatório, máx. 100 caracteres          |
| color     | string   | Hex válido, default `#4F46E5`             |
| archived  | boolean  | Default `false`                           |
| position  | integer  | Ordenação manual no dashboard             |

### Items

| Campo        | Tipo     | Regras                                    |
|--------------|----------|-------------------------------------------|
| task_list_id | FK       | Obrigatório · `ON DELETE CASCADE`         |
| title        | string   | Obrigatório, máx. 255 caracteres          |
| completed    | boolean  | Default `false`                           |
| due_date     | date     | Opcional · vencido = destaque vermelho     |
| priority     | integer  | 0 (baixa), 1 (média), 2 (alta)           |
| recurrence   | integer  | Enum: 0 (none), 1 (daily), 2 (weekly), 3 (monthly). Default: `none` |
| position     | integer  | Ordenação via drag-and-drop               |

### Gamification Profiles (1:1 com User)

| Campo             | Tipo     | Regras                                    |
|-------------------|----------|-------------------------------------------|
| user_id           | FK       | Obrigatório, único · `ON DELETE CASCADE`  |
| xp                | integer  | Default `0` · Nunca negativo              |
| level             | integer  | Default `1` · Calculado a partir do XP    |
| current_streak    | integer  | Default `0` · Dias consecutivos           |
| longest_streak    | integer  | Default `0` · Recorde pessoal             |
| last_completed_at | date     | Última data com tarefa concluída          |

### Achievements (catálogo fixo)

| Campo        | Tipo     | Regras                                |
|--------------|----------|---------------------------------------|
| key          | string   | Único · Identificador (ex: `first_task`) |
| title        | string   | Nome exibido (ex: "Primeira Tarefa")  |
| description  | string   | Descrição curta                       |
| icon         | string   | Emoji ou classe CSS                   |
| xp_reward    | integer  | XP concedido ao desbloquear           |

### User Achievements (N:N)

| Campo          | Tipo     | Regras                                |
|----------------|----------|---------------------------------------|
| user_id        | FK       | Obrigatório · `ON DELETE CASCADE`     |
| achievement_id | FK       | Obrigatório                           |
| unlocked_at    | datetime | Data/hora do desbloqueio              |

> Índice único em `[user_id, achievement_id]` — cada conquista é desbloqueada uma única vez.

### Friendships (N:N self-referencing)

| Campo          | Tipo     | Regras                                |
|----------------|----------|---------------------------------------|
| user_id        | FK       | Obrigatório · `ON DELETE CASCADE`     |
| friend_id      | FK       | Obrigatório · `ON DELETE CASCADE`     |
| status         | integer  | Enum: `pending` (0), `accepted` (1)  |

> Índice único em `[user_id, friend_id]` — evita convites duplicados. Relação bidirecional: ao aceitar, cria o registro inverso.

### Tabela de XP

| Ação                             | XP ganho |
|----------------------------------|:---:|
| Concluir item de prioridade baixa  | +5  |
| Concluir item de prioridade média  | +10 |
| Concluir item de prioridade alta   | +20 |
| Concluir item no prazo (due_date)  | +5 (bônus) |
| Completar 100% de uma lista        | +30 (bônus) |
| Manter streak diário               | +10/dia |

### Tabela de Níveis

| Nível | XP necessário | Título         |
|:---:|:---:|---|
| 1   | 0      | Iniciante       |
| 2   | 100    | Organizado      |
| 3   | 300    | Produtivo       |
| 4   | 600    | Eficiente       |
| 5   | 1000   | Mestre das Tasks|

### Conquistas (seed inicial)

| Key              | Título                | Condição                        | XP  |
|------------------|-----------------------|---------------------------------|:---:|
| `first_task`     | Primeira Tarefa       | Concluir 1 item                 | 10  |
| `ten_tasks`      | Dez de Dez            | Concluir 10 itens               | 25  |
| `fifty_tasks`    | Meio Centenário       | Concluir 50 itens               | 50  |
| `first_list`     | Listeiro              | Criar primeira lista            | 10  |
| `list_complete`  | Missão Cumprida       | Completar 100% de uma lista     | 30  |
| `streak_3`       | Constância            | 3 dias consecutivos             | 20  |
| `streak_7`       | Semana Produtiva      | 7 dias consecutivos             | 50  |
| `streak_30`      | Maratonista           | 30 dias consecutivos            | 150 |
| `high_priority`  | Prioridade Máxima     | Concluir 10 itens de alta prior.| 40  |
| `on_time`        | Pontualidade          | Concluir 5 itens antes do prazo | 30  |

### Decisões-chave

- **`1:N` e não `N:N`:** Cada lista pertence a um dono, cada item a uma lista. Sem compartilhamento no escopo — evita tabelas intermediárias desnecessárias.
- **`ON DELETE CASCADE`:** Garantia no banco de que excluir um user/lista remove os filhos. O `dependent: :destroy` no Rails é a camada de aplicação; o constraint é a rede de segurança.
- **`has_secure_password` e não Devise:** Para login simples, é suficiente e mais fácil de explicar. Devise seria overengineering sem OAuth ou recuperação de senha.
- **`archived` e não soft-delete:** Semanticamente claro — "guardar" é diferente de "excluir". Boolean simples, sem gem extra.
- **`enum` para priority:** Inteiro no banco, nome legível no código (`item.priority_high?`). Mais performático que string.
- **Gamification Profile separado (1:1):** Isola dados de gamificação da tabela `users`. Se no futuro removermos gamificação, basta dropar a tabela.
- **Achievements como catálogo + junção:** Padrão N:N clássico. Conquistas são pré-definidas (seed), o que é desbloqueado é registrado em `user_achievements`.
- **Lógica de XP em Service Object:** Calcular XP, verificar conquistas e atualizar streak envolve múltiplos models — justifica um `GamificationService`.
- **Friendships como self-referencing N:N:** Relação bidirecional com status (pending/accepted). Ao aceitar convite, cria registro inverso. Demonstra domínio do pattern clássico de self-referencing.

---

## 4. Arquitetura

### Stack justificada

| Camada        | Tecnologia                   | Por quê                                         |
|---------------|------------------------------|--------------------------------------------------|
| Backend       | Rails 7.1                    | Requisito do desafio, produtividade alta          |
| Banco         | PostgreSQL                   | Robusto, suporte nativo no Rails                  |
| Frontend      | Hotwire (Turbo + Stimulus)   | Integrado ao Rails, UX de SPA sem SPA             |
| Estilização   | TailwindCSS                  | Design moderno com pouco CSS manual               |
| Testes        | RSpec + FactoryBot           | Padrão de mercado, boa legibilidade               |
| Drag-and-drop | SortableJS via Stimulus      | Leve, compatível com Turbo                        |

### Controllers (6)

| Controller            | Responsabilidade                        |
|-----------------------|-----------------------------------------|
| `ApplicationController` | `current_user`, `require_authentication` |
| `SessionsController`    | Login e logout                         |
| `RegistrationsController`| Cadastro de novo usuário              |
| `TaskListsController`   | CRUD de listas + arquivar/restaurar    |
| `ItemsController`       | CRUD de itens + toggle concluído       |
| `GamificationController`| Perfil do jogador + conquistas         |
| `FriendshipsController` | Enviar, aceitar, recusar, remover amigos |
| `LeaderboardController` | Ranking de XP entre amigos             |

### Service Objects (1)

| Service                  | Responsabilidade                                             |
|--------------------------|--------------------------------------------------------------|
| `GamificationService`   | Conceder XP, verificar level-up, checar conquistas, atualizar streak |

### Rotas RESTful

| Método | Path                                  | Ação                    |
|--------|---------------------------------------|-------------------------|
| GET    | `/login`                              | Formulário de login     |
| POST   | `/login`                              | Autenticação            |
| DELETE | `/logout`                             | Logout                  |
| GET    | `/signup`                             | Formulário de cadastro  |
| POST   | `/signup`                             | Criar conta             |
| GET    | `/task_lists`                         | Dashboard (root)        |
| POST   | `/task_lists`                         | Criar lista             |
| GET    | `/task_lists/:id`                     | Ver lista + itens       |
| PATCH  | `/task_lists/:id`                     | Atualizar lista         |
| DELETE | `/task_lists/:id`                     | Excluir lista           |
| PATCH  | `/task_lists/:id/archive`             | Arquivar                |
| PATCH  | `/task_lists/:id/restore`             | Restaurar               |
| POST   | `/task_lists/:id/items`               | Criar item              |
| PATCH  | `/task_lists/:id/items/:id`           | Atualizar item          |
| DELETE | `/task_lists/:id/items/:id`           | Excluir item            |
| PATCH  | `/task_lists/:id/items/:id/toggle`    | Toggle concluído        |
| GET    | `/profile`                            | Perfil de gamificação   |
| GET    | `/profile/achievements`               | Lista de conquistas     |
| GET    | `/friends`                            | Lista de amigos         |
| POST   | `/friends`                            | Enviar convite          |
| PATCH  | `/friends/:id/accept`                 | Aceitar convite         |
| DELETE | `/friends/:id`                        | Recusar/remover amigo   |
| GET    | `/leaderboard`                        | Ranking entre amigos    |

### Princípios de desacoplamento

- **Scoped queries sempre:** `current_user.task_lists.find(id)` — nunca `TaskList.find(id)`. Garante isolamento entre usuários.
- **Fat model, skinny controller:** Scopes, validações e métodos de domínio no model. Controller só orquestra.
- **Helpers para views:** Lógica de apresentação (badges, cores) em helpers, nunca nas views.
- **Services para lógica cross-model:** `GamificationService` é chamado pelo `ItemsController#toggle` — encapsula XP + conquistas + streak sem poluir o controller.
- **Callback no model vs. Service:** O toggle do item dispara o service via controller (não via callback `after_update`) para manter o model desacoplado da gamificação.

---

## 5. Fluxos do Usuário

### Wireframes

**Login (`/login`)**
```
┌─────────────────────────────────────────┐
│              🔒 QuestLog                │
│                                         │
│    ┌─────────────────────────────┐      │
│    │ Email                       │      │
│    └─────────────────────────────┘      │
│    ┌─────────────────────────────┐      │
│    │ Senha                       │      │
│    └─────────────────────────────┘      │
│                                         │
│         [ Entrar ]                      │
│    Não tem conta? Cadastre-se           │
└─────────────────────────────────────────┘
```

**Dashboard (`/task_lists`)**
```
┌──────────────────────────────────────────────────────────┐
│  [QuestLog]        🔥 5 dias · Nv.3 Produtivo · 340 XP  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Minhas Listas                    [+ Nova Lista]         │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ 🟣 Compras   │  │ 🔵 Estudos   │  │ 🟢 Trabalho  │   │
│  │ ████████░░ 6/8│  │ ██░░░░░░ 2/7│  │ ██████████ ✓ │   │
│  │ [Editar]     │  │ [Editar]     │  │ [Arquivar]   │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                          │
│  ─── Arquivadas (2) ────────────────────────────────     │
│  │ Viagem · [Restaurar] [Excluir]                  │     │
└──────────────────────────────────────────────────────────┘
```

**Show Lista (`/task_lists/:id`)**
```
┌──────────────────────────────────────────────────────────┐
│  [← Voltar]   [QuestLog]        🔥 5 · Nv.3 · 340 XP   │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  🟣 Compras da semana          [Editar] [Arquivar]       │
│  ████████████░░░░ 6/8 itens (75%)                        │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │ + Adicionar item...                     [Adicionar]│  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  Pendentes ─────────────────────────────────────────     │
│  ☐ 🔴 Comprar arroz             📅 20/03       [⋮]      │
│  ☐ 🟡 Papel toalha              —              [⋮]      │
│                                                          │
│  Concluídos ────────────────────────────────────────     │
│  ☑ ~~Leite~~                                   [⋮]      │
│  ☑ ~~Café~~                                    [⋮]      │
└──────────────────────────────────────────────────────────┘
```

### Hotwire — Mapeamento de Turbo Frames e Streams

| Componente              | Tipo          | Frame/Target ID      | Comportamento                                   |
|-------------------------|:---:|----------------------|-------------------------------------------------|
| Form novo item          | Turbo Frame   | `new_item`           | Submete e limpa sem recarregar a lista           |
| Cada item               | Turbo Frame   | `item_<id>`          | Editar/toggle atualiza só aquele item            |
| Criar item              | Turbo Stream  | `append → #items`    | Item aparece no final da lista de pendentes      |
| Excluir item            | Turbo Stream  | `remove → #item_<id>`| Item desaparece instantaneamente                 |
| Toggle concluído        | Turbo Stream  | `replace → #item_<id>`| Re-renderiza com strikethrough, move de seção   |
| Criar lista             | Turbo Stream  | `prepend → #task_lists`| Card aparece no topo do dashboard              |
| Arquivar lista          | Turbo Stream  | `remove → #task_list_<id>`| Card some do dashboard                      |
| XP e nível (navbar)     | Turbo Stream  | `replace → #gamification_bar`| Atualiza barra de XP e badge de nível   |
| Toast de conquista      | Turbo Stream  | `append → #notifications`| Toast animado com ícone e título             |

### 5.1 Onboarding

```
Acesso à app → Tela de Login → [Não tem conta?] → Cadastro → Dashboard
```

### 5.2 Dashboard (gerenciar listas)

```
Dashboard
  ├── [+ Nova Lista] → formulário inline → lista aparece (Turbo Stream)
  ├── Clicar no card → Tela da Lista
  ├── [Arquivar] → lista some → vai para seção "Arquivadas"
  └── Seção Arquivadas → [Restaurar] ou [Excluir]
```

**O que o usuário vê:** Cards coloridos com barra de progresso (`6/8 itens`), listas arquivadas em seção colapsável, e na navbar: nível atual, XP e streak (🔥).

### 5.3 Dentro de uma lista (gerenciar itens)

```
Tela da Lista
  ├── Input inline → [Adicionar] → item aparece (Turbo Stream)
  ├── Checkbox → toggle → move para seção "Concluídos" (Turbo Stream)
  ├── Menu [⋮] → Editar / Excluir / Alterar prioridade
  └── Drag handle (≡) → arrastar para reordenar (Stimulus)
```

**O que o usuário vê:** Pendentes no topo, concluídos (com strikethrough) embaixo. Badges de prioridade (🔴🟡🟢), prazo em vermelho se vencido. Ao concluir um item: animação de **+XP** flutuante e notificação de conquista se desbloqueada. Tudo sem reload.

### 5.4 Percepção de SPA via Turbo

| Ação do usuário      | Resultado no browser                     | Tecnologia       |
|----------------------|------------------------------------------|------------------|
| Criar item           | Item aparece, input limpa                | Turbo Stream     |
| Toggle concluído     | Item desliza para seção correta          | Turbo Stream     |
| Excluir item         | Item desaparece                          | Turbo Stream     |
| Navegar entre telas  | Transição sem reload completo            | Turbo Drive      |
| Arrastar item        | Reordena no DOM + persiste posição       | Stimulus + fetch |
| Concluir item        | Animação +XP flutuante, barra XP atualiza | Turbo Stream     |
| Desbloquear conquista| Toast notification com ícone e título     | Turbo Stream     |

---

## 6. Diferenciais

### 🎮 Gamificação

O principal diferencial da aplicação. Transforma produtividade em jogo.

**Sistema de XP:** Cada item concluído dá XP proporcional à prioridade. Bônus por concluir no prazo e por completar 100% de uma lista.

**Níveis:** 5 níveis com títulos (Iniciante → Mestre das Tasks). A barra de XP aparece na navbar, dando feedback constante de progresso.

**Streaks (🔥):** Dias consecutivos com pelo menos 1 tarefa concluída. O streak aparece na navbar e motiva uso diário. Perder o streak zera o contador — mecânica comprovada de retenção.

**Conquistas (🏆):** 10 achievements desbloqueáveis por marcos (primeira tarefa, 7 dias de streak, 50 tarefas, etc.). Ao desbloquear, aparece um toast notification com animação. Tela de conquistas mostra todas (desbloqueadas em cores, travadas em cinza).

**Por que funciona:** Gamificação transforma a satisfação implícita de "riscar algo da lista" em feedback explícito (+XP, level up, conquista). É o mesmo princípio de apps como Duolingo e Todoist Karma.

**Na entrevista:** "Implementei um `GamificationService` que encapsula toda a lógica de XP, nivel e conquistas. Ele é chamado quando o item é marcado como concluído, verifica se algum achievement foi desbloqueado, e responde com Turbo Streams para atualizar a UI em tempo real — sem reload."

### 🎨 Cores personalizadas nas listas

Cada lista tem uma cor (seletor hex) que aparece na borda do card e no header da tela. Melhora organização visual com implementação mínima.

### 📊 Barra de progresso

Cada card mostra `concluídos / total` com barra visual. Feedback imediato que incentiva o usuário a completar a lista.

### ⚡ Hotwire (Turbo Streams)

CRUD de itens sem reload. A app parece SPA, mas é server-rendered com HTML. Demonstra domínio de feature moderna do Rails sem complexidade de framework JS.

### 🔃 Drag-and-drop

Reordenação via arrastar com SortableJS + Stimulus (~20 linhas de JS). Persiste ordem via PATCH. Impressiona visualmente com pouco código.

### 📅 Prazo com destaque

Itens vencidos em vermelho, vencimento "hoje" em amarelo. Método `overdue?` no model — sem lógica na view.

### 🏷️ Prioridade visual

Badges coloridos (alta/média/baixa) com `enum` do Rails — legível no código, performático no banco.

### 📦 Arquivamento

Listas finalizadas podem ser arquivadas e restauradas. Boolean simples, sem gem — mas comunica maturidade de produto.

### 🔍 Busca e filtros

Buscar listas por título. Filtrar itens por status e prioridade. Scopes no model, sem gem de busca.

### 👥 Ranking entre amigos

Sistema de amizades com convite por email. Leaderboard exibe ranking de XP entre amigos aceitos (XP total + XP semanal). Perfil público mostra nível, streak e conquistas desbloqueadas.

**Self-referencing N:N:** Tabela `friendships` com `user_id` + `friend_id` + `status`. Ao aceitar, cria registro bidirecional. Pattern clássico de entrevista Rails.

**Na entrevista:** "Implementei amizades como uma relação N:N self-referencing. A tabela `friendships` tem um `status` enum (pending/accepted) e ao aceitar um convite, crio o registro inverso automaticamente para que a relação seja bidirecional. O leaderboard faz um JOIN com `gamification_profiles` e ordena por XP."

### 🔁 Tarefas recorrentes

Itens podem ser configurados como recorrentes (diário, semanal, mensal). Ao concluir um item recorrente, o sistema marca como concluído e **cria automaticamente um novo item** com a próxima `due_date`. Mecânica similar ao Todoist.

**Enum no model:** `recurrence` com valores `none`, `daily`, `weekly`, `monthly`. Ao concluir, o `RecurrenceService` calcula o próximo prazo e clona o item.

**Por que funciona:** Combina com gamificação — cada conclusão de item recorrente dá XP normalmente. Incentiva hábitos diários e reforça o streak.

**Na entrevista:** "Ao concluir um item recorrente, crio um clone com a próxima `due_date` calculada. Cada conclusão contábiliza XP normalmente, reforçando o loop de gamificação. O pattern é o mesmo do Todoist."
