from io.hevo.api import Event

def transform(event):
    props = event.getProperties()
    name  = event.getEventName()

    if name == 'customers':
        email = props.get('email') or ''
        at = email.find('@')
        if at > 0:
            props['username'] = email[:at]

    if name == 'orders':
        status = (props.get('status') or '').strip().lower()
        mapping = {
            'placed': 'order_placed',
            'shipped': 'order_shipped',
            'delivered': 'order_delivered',
            'cancelled': 'order_cancelled'
        }
        event_type = mapping.get(status, 'unknown_status')

        new_props = {
            "order_id":    props.get("id"),
            "customer_id": props.get("customer_id"),
            "event_type":  event_type,
            "event_time":  props.get("updated_at") or props.get("created_at")
        }

        new_event = Event("order_events", new_props)
        return [event, new_event]

    return event
