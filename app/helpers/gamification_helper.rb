module GamificationHelper
  def xp_percentage(profile)
    profile.xp_progress_percentage
  end

  def level_title(level)
    case level
    when 1..2 then "Novato"
    when 3..4 then "Aventureiro"
    when 5..9 then "Mestre das Tarefas"
    else "Lenda Viva"
    end
  end

  def streak_display(profile)
    content_tag(:span, "🔥", role: "img", aria: { label: "streak" }) + " #{profile.streak_days} dias"
  end
end
