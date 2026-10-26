@extends('admin.layout')
@section('title', $cfg['label'])
@section('content')
<div class="page-head">
  <h1>{{ $cfg['icon'] }} {{ $cfg['label'] }}</h1>
  <a class="btn primary" href="{{ route('admin.section.create', ['section' => $section]) }}">+ Add {{ $cfg['singular'] }}</a>
</div>

<div class="card table-wrap">
  @if($items->isEmpty())
    <p class="muted">Nothing here yet. Click “Add {{ $cfg['singular'] }}” to create the first one.</p>
  @else
    <table>
      <thead>
        <tr>
          <th>Order</th>
          @foreach($cfg['columns'] as $label)<th>{{ $label }}</th>@endforeach
          <th class="right">Actions</th>
        </tr>
      </thead>
      <tbody>
        @foreach($items as $item)
        <tr>
          <td>{{ $item->sort_order }}</td>
          @foreach($cfg['columns'] as $col => $label)
            <td>
              @if(is_bool($item->{$col}))
                {{ $item->{$col} ? '✓' : '—' }}
              @else
                {{ \Illuminate\Support\Str::limit((string) $item->{$col}, 70) }}
              @endif
            </td>
          @endforeach
          <td class="right actions">
            <a class="btn small" href="{{ route('admin.section.edit', ['section' => $section, 'id' => $item->id]) }}">Edit</a>
            <form method="POST" action="{{ route('admin.section.destroy', ['section' => $section, 'id' => $item->id]) }}" onsubmit="return confirm('Delete this {{ $cfg['singular'] }}?')">
              @csrf
              @method('DELETE')
              <button class="btn small danger" type="submit">Delete</button>
            </form>
          </td>
        </tr>
        @endforeach
      </tbody>
    </table>
  @endif
</div>
@endsection
