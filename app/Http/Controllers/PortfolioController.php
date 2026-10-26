<?php

namespace App\Http\Controllers;

use App\Models\User;

class PortfolioController extends Controller
{
    public function home()
    {
        $default = config('portfolio.default_user');

        if ($default) {
            $user = User::where('username', $default)->where('is_active', true)->first();
            if ($user) {
                return $this->render($user);
            }
        }

        $users = User::where('is_active', true)
            ->whereNotNull('username')
            ->whereHas('profile', fn ($q) => $q->where('is_public', true))
            ->with('profile')
            ->orderBy('name')
            ->get();

        return view('home', compact('users'));
    }

    public function show(string $username)
    {
        $user = User::where('username', strtolower($username))->where('is_active', true)->firstOrFail();

        return $this->render($user);
    }

    private function render(User $user)
    {
        $profile = $user->ensureProfile();

        $viewer = auth()->user();
        $canPreview = $viewer && ($viewer->id === $user->id || $viewer->isAdmin());
        abort_unless($profile->is_public || $canPreview, 404);

        $user->load(['stats', 'highlights', 'experiences', 'skillCategories', 'projects', 'researchTopics']);

        return view('portfolio', ['user' => $user, 'p' => $profile]);
    }
}
