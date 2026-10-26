@extends('admin.layout')
@section('title', ($item->exists ? 'Edit ' : 'Add ') . $cfg['singular'])
@section('content')
<div class="page-head">
  <h1>{{ $item->exists ? 'Edit' : 'Add' }} {{ $cfg['singular'] }}</h1>
  <a class="btn secondary" href="{{ route('admin.section.index', ['section' => $section]) }}">← Back</a>
</div>

<form method="POST" class="form narrow"
      action="{{ $item->exists
        ? route('admin.section.update', ['section' => $section, 'id' => $item->id])
        : route('admin.section.store', ['section' => $section]) }}">
  @csrf
  @if($item->exists) @method('PUT') @endif

  <div class="card">
    @foreach($cfg['fields'] as $f)
      @include('admin._field', ['f' => $f, 'model' => $item])
    @endforeach

    @include('admin._field', ['model' => $item, 'f' => [
      'name' => 'sort_order', 'label' => 'Display order', 'type' => 'number',
      'help' => 'Lower numbers appear first. Leave empty to add at the end.',
    ]])
  </div>

  <button class="btn primary" type="submit">{{ $item->exists ? 'Save changes' : 'Create' }}</button>
</form>
@endsection
