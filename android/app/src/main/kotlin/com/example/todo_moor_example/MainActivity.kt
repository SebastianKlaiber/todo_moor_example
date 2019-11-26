package com.example.todo_moor_example

import android.content.Intent
import android.os.Bundle
import androidx.core.content.ContextCompat
import com.example.todo_moor_example.database.AppDatabase
import com.example.todo_moor_example.database.AppExecutors
import com.example.todo_moor_example.model.Task
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val CHANNEL = "database/demo"

    private var mDb: AppDatabase? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initDb" -> {
                    mDb = AppDatabase.getInstance(applicationContext)
                    result.success(mDb?.isOpen)
                }
                "getMessage" -> {
                    retrieveTasks(result)
                }
                "updateTask" -> {
                    AppExecutors.getInstance().diskIO().execute {
                        val name: String = call.arguments as String

                        updateTask(result, name)
                    }
                }
            }
        }
    }

    private fun retrieveTasks(result: MethodChannel.Result) {
        AppExecutors.getInstance().diskIO().execute {
            val taskDao = mDb?.taskDao()
            val tasks: List<Task?>? = taskDao?.loadAllTasks()
            var name: String? = "Empty"
            if (!tasks.isNullOrEmpty()) {
                val task: Task? = tasks.first()
                task?.let {
                    name = task.name + " ${task.isChecked}"
                }
            }
            runOnUiThread {
                result.success(name)
            }
        }
    }

    private fun updateTask(result: MethodChannel.Result, name: String) {
        val taskDao = mDb?.taskDao()
        val task = taskDao?.loadTaskByName(name)
        task?.let {
            task.name = "${task.name} changed from Android"
            taskDao.updateTask(task)
            runOnUiThread {
                result.success(true)
                startService()
            }
        }
    }

    private fun startService() {
        val serviceIntent = Intent(this, ForegroundService::class.java)
        serviceIntent.putExtra("inputExtra", "Foreground Service Example in Android")
        ContextCompat.startForegroundService(this, serviceIntent)
    }
}
