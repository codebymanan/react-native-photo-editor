package com.photoeditor.editor.filters

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.StringRes
import androidx.recyclerview.widget.RecyclerView
import com.photoeditor.R
import ja.burhanrashid52.photoeditor.PhotoFilter
import java.io.IOException
import java.util.ArrayList

/**
 * @author [Burhanuddin Rashid](https://github.com/burhanrashid52)
 * @version 0.1.2
 * @since 5/23/2018
 */
class FilterViewAdapter(private val mFilterListener: FilterListener) :
    RecyclerView.Adapter<FilterViewAdapter.ViewHolder>() {
    private val mFilterList: MutableList<FilterModel> = ArrayList()

    private class FilterModel(
        val mAssetPath: String,
        val mFilter: PhotoFilter,
        @StringRes val mFilterName: Int
    )

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.pe_row_filter_view, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val filter = mFilterList[position]
        val fromAsset = getBitmapFromAsset(holder.itemView.context, filter.mAssetPath)
        holder.mImageFilterView.setImageBitmap(fromAsset)
        holder.mTxtFilterName.setText(filter.mFilterName)
    }

    override fun getItemCount(): Int {
        return mFilterList.size
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val mImageFilterView: ImageView = itemView.findViewById(R.id.imgFilterView)
        val mTxtFilterName: TextView = itemView.findViewById(R.id.txtFilterName)

        init {
            itemView.setOnClickListener{
                mFilterListener.onFilterSelected(
                    mFilterList[layoutPosition].mFilter
                )
            }
        }
    }

    private fun getBitmapFromAsset(context: Context, strName: String): Bitmap? {
        val assetManager = context.assets
        return try {
            val istr = assetManager.open(strName)
            BitmapFactory.decodeStream(istr)
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }

    private fun setupFilters() {
        mFilterList.add(FilterModel("filters/original.jpg", PhotoFilter.NONE, R.string.pe_filter_none))
        mFilterList.add(FilterModel("filters/auto_fix.png", PhotoFilter.AUTO_FIX, R.string.pe_filter_auto_fix))
        mFilterList.add(FilterModel("filters/brightness.png", PhotoFilter.BRIGHTNESS, R.string.pe_filter_brightness))
        mFilterList.add(FilterModel("filters/contrast.png", PhotoFilter.CONTRAST, R.string.pe_filter_contrast))
        mFilterList.add(FilterModel("filters/documentary.png", PhotoFilter.DOCUMENTARY, R.string.pe_filter_documentary))
        mFilterList.add(FilterModel("filters/dual_tone.png", PhotoFilter.DUE_TONE, R.string.pe_filter_duo_tone))
        mFilterList.add(FilterModel("filters/fill_light.png", PhotoFilter.FILL_LIGHT, R.string.pe_filter_fill_light))
        mFilterList.add(FilterModel("filters/fish_eye.png", PhotoFilter.FISH_EYE, R.string.pe_filter_fish_eye))
        mFilterList.add(FilterModel("filters/grain.png", PhotoFilter.GRAIN, R.string.pe_filter_grain))
        mFilterList.add(FilterModel("filters/gray_scale.png", PhotoFilter.GRAY_SCALE, R.string.pe_filter_gray_scale))
        mFilterList.add(FilterModel("filters/lomish.png", PhotoFilter.LOMISH, R.string.pe_filter_lomish))
        mFilterList.add(FilterModel("filters/negative.png", PhotoFilter.NEGATIVE, R.string.pe_filter_negative))
        mFilterList.add(FilterModel("filters/posterize.png", PhotoFilter.POSTERIZE, R.string.pe_filter_posterize))
        mFilterList.add(FilterModel("filters/saturate.png", PhotoFilter.SATURATE, R.string.pe_filter_saturate))
        mFilterList.add(FilterModel("filters/sepia.png", PhotoFilter.SEPIA, R.string.pe_filter_sepia))
        mFilterList.add(FilterModel("filters/sharpen.png", PhotoFilter.SHARPEN, R.string.pe_filter_sharpen))
        mFilterList.add(FilterModel("filters/temprature.png", PhotoFilter.TEMPERATURE, R.string.pe_filter_temperature))
        mFilterList.add(FilterModel("filters/tint.png", PhotoFilter.TINT, R.string.pe_filter_tint))
        mFilterList.add(FilterModel("filters/vignette.png", PhotoFilter.VIGNETTE, R.string.pe_filter_vignette))
        mFilterList.add(FilterModel("filters/cross_process.png", PhotoFilter.CROSS_PROCESS, R.string.pe_filter_cross_process))
        mFilterList.add(FilterModel("filters/b_n_w.png", PhotoFilter.BLACK_WHITE, R.string.pe_filter_black_white))
        mFilterList.add(FilterModel("filters/flip_horizental.png", PhotoFilter.FLIP_HORIZONTAL, R.string.pe_filter_flip_horizontal))
        mFilterList.add(FilterModel("filters/flip_vertical.png", PhotoFilter.FLIP_VERTICAL, R.string.pe_filter_flip_vertical))
        mFilterList.add(FilterModel("filters/rotate.png", PhotoFilter.ROTATE, R.string.pe_filter_rotate))
    }

    init {
        setupFilters()
    }
}