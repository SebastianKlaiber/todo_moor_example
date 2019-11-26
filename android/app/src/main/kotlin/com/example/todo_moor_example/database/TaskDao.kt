package com.example.todo_moor_example.database

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Update
import com.example.todo_moor_example.model.Task

@Dao
interface TaskDao {
    @Query("SELECT * FROM Tasks")
    fun loadAllTasks(): List<Task?>?

    @Update
    fun updateTask(task: Task?)

    @Query("SELECT * FROM TASKS WHERE id = :id")
    fun loadTaskById(id: Int): Task?

    @Query("SELECT * FROM TASKS WHERE name = :name")
    fun loadTaskByName(name: String): Task?
}