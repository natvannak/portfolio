<?php

namespace App\Http\Controllers;

use App\Support\Portfolio;
use App\Support\Sections;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

/**
 * One controller that provides full CRUD for every repeatable section
 * (stats, about cards, experience, skills, projects, research topics).
 * Everything is scoped to the target user, so users can only touch their own rows.
 */
class SectionController extends Controller
{
    private function cfg(string $section): array
    {
        return Sections::get($section) ?? abort(404);
    }

    private function rules(array $cfg): array
    {
        $rules = ['sort_order' => ['nullable', 'integer', 'min:0', 'max:9999']];
        foreach ($cfg['fields'] as $f) {
            $rules[$f['name']] = $f['rules'];
        }

        return $rules;
    }

    private function find(array $cfg, int $id)
    {
        return Portfolio::target()->{$cfg['relation']}()->findOrFail($id);
    }

    public function index(string $section)
    {
        $cfg = $this->cfg($section);
        $items = Portfolio::target()->{$cfg['relation']}()->get();

        return view('admin.section.index', compact('section', 'cfg', 'items'));
    }

    public function create(string $section)
    {
        $cfg = $this->cfg($section);
        $class = $cfg['model'];

        return view('admin.section.form', ['section' => $section, 'cfg' => $cfg, 'item' => new $class]);
    }

    public function store(Request $request, string $section): RedirectResponse
    {
        $cfg = $this->cfg($section);
        $data = $request->validate($this->rules($cfg));

        $relation = Portfolio::target()->{$cfg['relation']}();
        $data['sort_order'] = $data['sort_order'] ?? ((int) $relation->max('sort_order') + 1);
        $relation->create($data);

        return redirect()->route('admin.section.index', ['section' => $section])
            ->with('status', ucfirst($cfg['singular']) . ' added.');
    }

    public function edit(string $section, int $id)
    {
        $cfg = $this->cfg($section);

        return view('admin.section.form', ['section' => $section, 'cfg' => $cfg, 'item' => $this->find($cfg, $id)]);
    }

    public function update(Request $request, string $section, int $id): RedirectResponse
    {
        $cfg = $this->cfg($section);
        $item = $this->find($cfg, $id);

        $data = $request->validate($this->rules($cfg));
        $data['sort_order'] = $data['sort_order'] ?? 0;
        $item->update($data);

        return redirect()->route('admin.section.index', ['section' => $section])
            ->with('status', ucfirst($cfg['singular']) . ' updated.');
    }

    public function destroy(string $section, int $id): RedirectResponse
    {
        $cfg = $this->cfg($section);
        $this->find($cfg, $id)->delete();

        return redirect()->route('admin.section.index', ['section' => $section])
            ->with('status', ucfirst($cfg['singular']) . ' deleted.');
    }
}
