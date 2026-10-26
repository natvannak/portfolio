<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Support\Portfolio;
use App\Support\Sections;
use Illuminate\Http\RedirectResponse;

class DashboardController extends Controller
{
    public function index()
    {
        $target = Portfolio::target();
        $sections = Sections::all();

        $counts = [];
        foreach ($sections as $key => $cfg) {
            $counts[$key] = $target->{$cfg['relation']}()->count();
        }

        return view('admin.dashboard', [
            'target' => $target,
            'profile' => $target->ensureProfile(),
            'sections' => $sections,
            'counts' => $counts,
            'userCount' => auth()->user()->isAdmin() ? User::count() : null,
        ]);
    }

    public function stopManaging(): RedirectResponse
    {
        session()->forget('managing_user_id');

        return redirect()->route('admin.dashboard');
    }
}
