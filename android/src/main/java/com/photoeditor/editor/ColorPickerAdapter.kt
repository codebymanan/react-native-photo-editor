package com.photoeditor.editor

import com.photoeditor.R

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import androidx.core.content.ContextCompat
import java.util.ArrayList

/**
 * Created by Ahmed Adel on 5/8/17.
 */
class ColorPickerAdapter internal constructor(
    private var context: Context,
    colorPickerColors: List<Int>
) : RecyclerView.Adapter<ColorPickerAdapter.ViewHolder>() {
    private var inflater: LayoutInflater
    private val colorPickerColors: List<Int>
    private lateinit var onColorPickerClickListener: OnColorPickerClickListener

    internal constructor(context: Context) : this(context, getDefaultColors(context)) {
        this.context = context
        inflater = LayoutInflater.from(context)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = inflater.inflate(R.layout.pe_color_picker_item_list, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.colorPickerView.setBackgroundColor(colorPickerColors[position])
    }

    override fun getItemCount(): Int {
        return colorPickerColors.size
    }

    fun setOnColorPickerClickListener(onColorPickerClickListener: OnColorPickerClickListener) {
        this.onColorPickerClickListener = onColorPickerClickListener
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var colorPickerView: View = itemView.findViewById(R.id.color_picker_view)

        init {
            itemView.setOnClickListener {
                onColorPickerClickListener.onColorPickerClickListener(
                    colorPickerColors[adapterPosition]
                )
            }
        }
    }

    interface OnColorPickerClickListener {
        fun onColorPickerClickListener(colorCode: Int)
    }

    companion object {
        fun getDefaultColors(context: Context): List<Int> {
            val colorPickerColors = ArrayList<Int>()
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_blue_color_picker))
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_brown_color_picker))
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_green_color_picker))
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_orange_color_picker))
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_red_color_picker))
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_black))
            colorPickerColors.add(
                ContextCompat.getColor(
                    (context),
                    R.color.pe_red_orange_color_picker
                )
            )
            colorPickerColors.add(
                ContextCompat.getColor(
                    (context),
                    R.color.pe_sky_blue_color_picker
                )
            )
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_violet_color_picker))
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_white))
            colorPickerColors.add(ContextCompat.getColor((context), R.color.pe_yellow_color_picker))
            colorPickerColors.add(
                ContextCompat.getColor(
                    (context),
                    R.color.pe_yellow_green_color_picker
                )
            )
            return colorPickerColors
        }
    }

    init {
        inflater = LayoutInflater.from(context)
        this.colorPickerColors = colorPickerColors
    }
}