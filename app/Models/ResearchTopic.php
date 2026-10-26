<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ResearchTopic extends Model
{
    protected $table = 'research_topics';

    protected $guarded = ['id', 'user_id'];
}
