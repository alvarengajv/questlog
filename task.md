QL-06 - Model Item
#43

## Descricao
Implementar model Item com enum priority, enum recurrence, validacoes, scopes e metodos de dominio.

## Criterios de Aceite
- [ ] Enum priority: low(0), medium(1), high(2), default :low
- [ ] Enum recurrence: none(0), daily(1), weekly(2), monthly(3), default :none
- [ ] overdue? retorna true se due_date < Date.current e nao completado
- [ ] due_today? retorna true se due_date == Date.current
- [ ] recurring? retorna true se recurrence != none
- [ ] xp_value retorna 5 (low), 10 (medium), 20 (high)
- [ ] Scopes completed, pending, by_priority funcionam
- [ ] Testes de model passando
