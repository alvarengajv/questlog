module ItemsHelper
  def priority_badge(item)
    case item.priority
    when "high"
      content_tag(:span, "🔴 Alta", class: "text-red-600 bg-red-100 rounded px-2 py-1 text-xs font-bold")
    when "medium"
      content_tag(:span, "🟡 Média", class: "text-yellow-600 bg-yellow-100 rounded px-2 py-1 text-xs font-bold")
    when "low"
      content_tag(:span, "🟢 Baixa", class: "text-green-600 bg-green-100 rounded px-2 py-1 text-xs font-bold")
    else
      content_tag(:span, "⚪ Nenhuma", class: "text-gray-600 bg-gray-100 rounded px-2 py-1 text-xs font-bold")
    end
  end

  def due_date_class(item)
    if item.overdue?
      "text-red-500 font-bold"
    elsif item.due_today?
      "text-yellow-500 font-bold"
    else
      "text-gray-500"
    end
  end
end
