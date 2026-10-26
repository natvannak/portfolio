<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $table = 'projects';

    protected $guarded = ['id', 'user_id'];

    protected function casts(): array
    {
        return ['featured' => 'boolean'];
    }
}
