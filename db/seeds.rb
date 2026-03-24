# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

achievements = [
  { key: 'first_task', name: 'Primeira de Muitas', description: 'Complete sua primeira tarefa.', xp_reward: 50 },
  { key: 'streak_3', name: 'Em Chamas', description: 'Mantenha uma ofensiva de 3 dias.', xp_reward: 100 },
  { key: 'streak_7', name: 'Imparável', description: 'Mantenha uma ofensiva de 7 dias.', xp_reward: 300 },
  { key: 'level_2', name: 'Subindo de Nível', description: 'Alcance o Nível 2.', xp_reward: 0 },
  { key: 'level_5', name: 'Mestre das Tarefas', description: 'Alcance o nível máximo (5).', xp_reward: 0 },
  { key: 'first_list', name: 'Organizador', description: 'Crie sua primeira lista de tarefas.', xp_reward: 50 },
  { key: 'task_10', name: 'Dezena Vencedora', description: 'Complete 10 tarefas no total.', xp_reward: 150 },
  { key: 'task_50', name: 'Máquina de Produtividade', description: 'Complete 50 tarefas.', xp_reward: 500 },
  { key: 'task_100', name: 'Lenda Viva', description: 'Complete 100 tarefas. Você é uma lenda!', xp_reward: 1000 },
  { key: 'high_priority', name: 'Bombeiro', description: 'Complete uma tarefa de prioridade alta.', xp_reward: 100 }
]

achievements.each do |achv|
  Achievement.find_or_create_by!(key: achv[:key]) do |a|
    a.name = achv[:name]
    a.description = achv[:description]
    a.xp_reward = achv[:xp_reward]
  end
end

# Retroactively grant achievements to existing users who already qualify
User.find_each do |user|
  GamificationService.backfill_achievements!(user)
end
