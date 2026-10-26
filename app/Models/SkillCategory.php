<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SkillCategory extends Model
{
    protected $table = 'skill_categories';

    protected $guarded = ['id', 'user_id'];
}
