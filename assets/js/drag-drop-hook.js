import Sortable from "sortablejs";

const Hook = {
    mounted() {
        const s = Sortable.create(this.el, {
            group: {name: "draggable", pull: true, put: true},
            ghostClass: "bg-orange-500",
            dragClass: "bg-red-500",
            onEnd: e => {
                const colNumSuffix = "col-(.*)";
                const fromColIndex = parseInt(e.from.id.match(colNumSuffix)[1]);
                const toColIndex = parseInt(e.to.id.match(colNumSuffix)[1]);
                this.pushEvent("card-dropped", { from: [fromColIndex, e.oldIndex], to: [toColIndex, e.newIndex] });
            }
        });
        // TODO: remove
        console.log(`sortable created for ${this.el.id}`)
    }
}

export default Hook;