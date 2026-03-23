module ItemsHelper
  def priority_badge(item)
    case item.priority
    when "high"
      content_tag(:span, "🔴 Alta", class: "badge badge-high")
    when "medium"
      content_tag(:span, "🟡 Média", class: "badge badge-medium")
    when "low"
      content_tag(:span, "🟢 Baixa", class: "badge badge-low")
    else
      content_tag(:span, "—", class: "text-[var(--color-quest-gold-dim)] text-[10px]")
    end
  end

  def recurrence_badge(item)
    return unless item.recurring?

    label = case item.recurrence
    when "daily" then "Diária"
    when "weekly" then "Semanal"
    when "monthly" then "Mensal"
    end

    tooltip = "Recorrência #{label.downcase}"
    tooltip += " — próximo: #{item.due_date.strftime("%d/%m/%Y")}" if item.due_date.present?

    content_tag(:span, "🔁 #{label}", class: "badge badge-recurrence", title: tooltip)
  end

  def due_date_class(item)
    if item.overdue?
      "text-[var(--color-critical-hit)] font-semibold"
    elsif item.due_today?
      "text-[var(--color-xp-amber)] font-semibold"
    else
      "text-[var(--color-quest-gold-dim)]"
    end
  end
end
