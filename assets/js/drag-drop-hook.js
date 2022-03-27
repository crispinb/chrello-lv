import Sortable from "sortablejs";

const Hook = {
    mounted() {
        const s = Sortable.create(this.el, {
            group: {name: "draggable", pull: true, put: true},
            ghostClass: "bg-orange-500",
            dragClass: "bg-red-500",
            onEnd: e => {
                const colNumSuffix = "col-(.*)";
                const fromColumnIndex = parseInt(e.from.dataset.columnIndex)
                const toColumnIndex = parseInt(e.to.dataset.columnIndex)
                this.pushEvent("card-dropped", { from: [fromColumnIndex, e.oldIndex], to: [toColumnIndex, e.newIndex] });
            }
        });
        console.log(`sortable was created for ${this.el.id}`)
    }
}

export default Hook;