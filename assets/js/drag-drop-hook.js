import Sortable from "sortablejs";

const Hook = {
    mounted() {
        const s = Sortable.create(this.el, {
            group: "draggable",
            ghostClass: "bg-red-700",
            dragClass: "bg-cyan-800",
            onEnd: e => {
                this.pushEvent("card-dropped", { from: {col: e.from.id, index: e.oldIndex}, to: {col: e.to.id, index: e.newIndex} });
            }
        });
        console.log(`sortable created for ${this.el.id}`)
    }
}

export default Hook;