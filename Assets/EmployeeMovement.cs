using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EmployeeMovement : MonoBehaviour
{
    [SerializeField]
    private Transform target;

    public float speed;
    //private Vector2 targetPosition;

    // Start is called before the first frame update
    void Start()
    {
        //targetPosition = new Vector2(0.0f, 0.0f);

    }

    // Update is called once per frame
    void Update()
    {



        if (Input.GetMouseButtonDown(0))
        {
            //var currentPosition = this.transform.position;
            //var mousePosition = Input.mousePosition;
            //var desiredPosition = Camera.main.ScreenToWorldPoint(new Vector3(mousePosition.x, mousePosition.y, 10.0f));


            //Vector3 direction = desiredPosition - currentPosition;
            //Ray ray = new Ray(currentPosition, direction);
            //RaycastHit2D hit = Physics2D.Linecast(currentPosition, desiredPosition);

            //if (hit.collider != null && Vector2.Distance(currentPosition, hit.point) != 0f)
            //{
            //    targetPosition = hit.point;
            //}
            //else
            //{
            //    targetPosition = desiredPosition;
            //}


            //targetPosition = Camera.main.ScreenToWorldPoint(new Vector3(targetPosition.x, targetPosition.y, 10.0f));
        }


            //this.transform.position = Vector2.MoveTowards(this.transform.position, targetPosition, speed * Time.deltaTime);

    }

    //private void FixedUpdate()
    //{
    //    //var direction = targetPosition.normalized;
    //    gameObject.GetComponent<Rigidbody2D>().MovePosition(Vector2.MoveTowards(this.transform.position, targetPosition, speed * Time.deltaTime));
    //}
}
